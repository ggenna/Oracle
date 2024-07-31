function SaveToDisk (
    p_process in apex_plugin.t_process,
    p_plugin  in apex_plugin.t_plugin )
    return apex_plugin.t_process_exec_result 
  AS
  l_blob BLOB;
  l_filebrowse varchar2(1000);
  l_filebrowse_ok number default 0;
  l_dbdirectory varchar2(1000);
  l_filename varchar2(1000);
  l_filename_item varchar2(100);
  l_hash_item varchar2(100);
  --l_attr_filename varchar2(1000);
  l_file_type varchar2(20);
  l_max_file_size integer;
  l_doc_size integer;
  l_ret apex_plugin.t_process_exec_result; 
  
  PROCEDURE Blob2File
  ( 
    P_DIRECTORY      IN VARCHAR2,
    P_FILENAME       IN VARCHAR2,  
    p_blob           IN BLOB 
  ) 
  IS
    c_amount         BINARY_INTEGER := 32767;
    l_buffer         RAW(32767);
    l_clobLen        PLS_INTEGER;
    l_fHandler       utl_file.file_type;
    l_pos            PLS_INTEGER    := 1;
  
  BEGIN
  
    l_clobLen  := DBMS_LOB.GETLENGTH(p_blob);
    l_fHandler := UTL_FILE.FOPEN(P_DIRECTORY, P_FILENAME, 'wb', 32767);
    
    LOOP
      DBMS_LOB.READ(p_blob, c_amount, l_pos, l_buffer);     
      UTL_FILE.PUT_RAW(l_fHandler, l_buffer, true);
      l_pos := l_pos + c_amount;
    END LOOP;
  
    UTL_FILE.FCLOSE(l_fHandler);
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    UTL_FILE.FCLOSE(l_fHandler);
    
  WHEN OTHERS THEN
    if utl_file.is_open(l_fHandler) then
      UTL_FILE.FCLOSE(l_fHandler);
    end if;
    
   --Log error
   raise; 
  END Blob2File;
  
  function FileSizeInBytes(p_filesize varchar2)
  return integer
  as
  l_filesize varchar2(20);
  l_faktor integer default 1;
  l_posK integer default 0;
  l_posM integer default 0;
  l_posG integer default 0;
  l_pos integer default 0;
  l_ret number;
  begin
    if p_filesize is null then return null; end if;
    
    l_filesize := replace(upper(substr(p_filesize,1,20)),'.',',');
    l_posK := instr(l_filesize,'K');
    l_posM := instr(l_filesize,'M');
    l_posG := instr(l_filesize,'G');
  
    l_pos := least   (case l_posK when 0 then 99 else l_posK end, 
                      case l_posM when 0 then 99 else l_posM end,  
                      case l_posG when 0 then 99 else l_posG end);
                      
    if l_pos = 99 then l_faktor := 1; 
    elsif l_pos = l_posK then l_faktor := 1024; 
    elsif l_pos = l_posM then l_faktor := 1024*1024; 
    elsif l_pos = l_posG then l_faktor := 1024*1024*1024; 
    end if;
    
    if l_pos > 0 then 
      l_ret := to_number(trim(substr(l_filesize, 1,l_pos-1)));
      l_ret := l_ret * l_faktor;
    else
      l_ret := to_number(l_filesize);
    end if;
    return trunc(l_ret);
    exception    
      when others then  
      --Error loging
       return null;
  end FileSizeInBytes;

  function GetFileType(
    P_FILENAME VARCHAR2
  )
  return varchar2
  AS
  l_ret varchar2(20);
  l_pos number;
  BEGIN
  
    l_pos := INSTR(P_FILENAME, '.', -1, 1);
    if l_pos > 0 then
      l_ret := lower(SUBSTR(P_FILENAME, l_pos + 1)); 
    end if;
    
    return l_ret;
  end;
  
  function ChangeFileType (p_filename varchar2 , p_filetype varchar2)
  return varchar2
  as
  l_point_position number;
  begin
    l_point_position := INSTR(p_filename, '.', -1, 1);
    if p_filetype is null then
      if l_point_position > 1 then 
        return substr(p_filename, 1, l_point_position-1);
      end if;
    else
      if l_point_position = 0 then 
        return p_filename||'.'||p_filetype;
      else
        return SUBSTR(p_filename, 1,INSTR(p_filename, '.', -1, 1))||p_filetype;
      end if;
    end if;
    return p_filename; --without filetype before and now
  end;

  begin
    
    l_filebrowse := V(p_process.attribute_01);
    l_dbdirectory:= p_process.attribute_02;
    l_filename:= p_process.attribute_03;
    l_max_file_size:= FileSizeInBytes(p_process.attribute_04);
    l_filename_item := p_process.attribute_05;
    l_hash_item:= p_process.attribute_06;
   
     if l_filebrowse is null then  --do nothing when submit   
      return l_ret;
    end if;
    
    select count(*) into l_filebrowse_ok 
    from apex_application_page_items 
    where display_as_code = 'NATIVE_FILE' 
    and attribute_01 = 'WWV_FLOW_FILES' 
    and application_id = V('APP_ID')
    and page_id = V('APP_PAGE_ID') 
    and item_name = p_process.attribute_01;
    
    if l_filebrowse_ok <> 1 then
      l_ret.success_message := 'Item '||p_process.attribute_01||' is not File Browse item or dosen''t have defined WWV_FLOW_FILES for storage.';
      return l_ret;
    end if;
    
    select blob_content, doc_size 
    into l_blob, l_doc_size 
    from wwv_flow_files where name = l_filebrowse;
    
    if l_doc_size > l_max_file_size then
      l_ret.success_message := 'File size too big. Maximum allowed size is '||l_max_file_size||' bytes.';
      delete from wwv_flow_files where name = l_filebrowse;
    else
      l_filename := ChangeFileType(l_filename, GetFileType(l_filebrowse));--change file type to uploaded filetype

      if l_hash_item is not null then
        apex_util.set_session_state(l_hash_item, DBMS_CRYPTO.Hash(l_blob, DBMS_CRYPTO.HASH_SH1));
      end if;

      Blob2File(l_dbdirectory, l_filename, l_blob);
      delete from wwv_flow_files where name = l_filebrowse;
      if l_filename_item is not null then
        apex_util.set_session_state(l_filename_item, l_filename);
      end if;

      l_ret.success_message := p_process.success_message;
    end if;
    commit;
    return l_ret;
exception    
    when others then  
    l_ret.success_message := 'Error when moving file '||l_filebrowse||' from WWV_FLOW_FILES table to server disk '||
                             'on location (Oracle DB directory) '||l_dbdirectory||'\\'||l_filename||' . SQLERR: '||sqlerrm;  
    --log error

                  
    return l_ret;
    rollback;
  END SaveToDisk;