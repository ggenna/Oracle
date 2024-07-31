set define off
set verify off
set feedback off
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
begin wwv_flow.g_import_in_progress := true; end;
/
 
--       AAAA       PPPPP   EEEEEE  XX      XX
--      AA  AA      PP  PP  EE       XX    XX
--     AA    AA     PP  PP  EE        XX  XX
--    AAAAAAAAAA    PPPPP   EEEE       XXXX
--   AA        AA   PP      EE        XX  XX
--  AA          AA  PP      EE       XX    XX
--  AA          AA  PP      EEEEEE  XX      XX
prompt  Set Credentials...
 
begin
 
  -- Assumes you are running the script connected to SQL*Plus as the Oracle user APEX_040200 or as the owner (parsing schema) of the application.
  wwv_flow_api.set_security_group_id(p_security_group_id=>nvl(wwv_flow_application_install.get_workspace_id,51786122851064348));
 
end;
/

begin wwv_flow.g_import_in_progress := true; end;
/
begin 

select value into wwv_flow_api.g_nls_numeric_chars from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';

end;

/
begin execute immediate 'alter session set nls_numeric_characters=''.,''';

end;

/
begin wwv_flow.g_browser_language := 'en'; end;
/
prompt  Check Compatibility...
 
begin
 
-- This date identifies the minimum version required to import this file.
wwv_flow_api.set_version(p_version_yyyy_mm_dd=>'2012.01.01');
 
end;
/

prompt  Set Application ID...
 
begin
 
   -- SET APPLICATION ID
   wwv_flow.g_flow_id := nvl(wwv_flow_application_install.get_application_id,100);
   wwv_flow_api.g_id_offset := nvl(wwv_flow_application_install.get_offset,0);
null;
 
end;
/

prompt  ...ui types
--
 
begin
 
null;
 
end;
/

prompt  ...plugins
--
--application/shared_components/plugins/process_type/si_mirmas_savetodisk
 
begin
 
wwv_flow_api.create_plugin (
  p_id => 254910161854139662 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_type => 'PROCESS TYPE'
 ,p_name => 'SI.MIRMAS.SAVETODISK'
 ,p_display_name => 'SaveToDisk'
 ,p_supported_ui_types => 'DESKTOP'
 ,p_image_prefix => '#PLUGIN_PREFIX#'
 ,p_plsql_code => 
'function SaveToDisk ('||unistr('\000a')||
'    p_process in apex_plugin.t_process,'||unistr('\000a')||
'    p_plugin  in apex_plugin.t_plugin )'||unistr('\000a')||
'    return apex_plugin.t_process_exec_result '||unistr('\000a')||
'  AS'||unistr('\000a')||
'  l_blob BLOB;'||unistr('\000a')||
'  l_filebrowse varchar2(1000);'||unistr('\000a')||
'  l_filebrowse_ok number default 0;'||unistr('\000a')||
'  l_dbdirectory varchar2(1000);'||unistr('\000a')||
'  l_filename varchar2(1000);'||unistr('\000a')||
'  l_filename_item varchar2(100);'||unistr('\000a')||
'  l_hash_item varchar2(100);'||unistr('\000a')||
'  --l_attr_filename varchar2(1000);'||unistr('\000a')||
'  l_fi'||
'le_type varchar2(20);'||unistr('\000a')||
'  l_max_file_size integer;'||unistr('\000a')||
'  l_doc_size integer;'||unistr('\000a')||
'  l_ret apex_plugin.t_process_exec_result; '||unistr('\000a')||
'  '||unistr('\000a')||
'  PROCEDURE Blob2File'||unistr('\000a')||
'  ( '||unistr('\000a')||
'    P_DIRECTORY      IN VARCHAR2,'||unistr('\000a')||
'    P_FILENAME       IN VARCHAR2,  '||unistr('\000a')||
'    p_blob           IN BLOB '||unistr('\000a')||
'  ) '||unistr('\000a')||
'  IS'||unistr('\000a')||
'    c_amount         BINARY_INTEGER := 32767;'||unistr('\000a')||
'    l_buffer         RAW(32767);'||unistr('\000a')||
'    l_clobLen        PLS_INTEGER;'||unistr('\000a')||
'    l_fHandler       utl_file.fi'||
'le_type;'||unistr('\000a')||
'    l_pos            PLS_INTEGER    := 1;'||unistr('\000a')||
'  '||unistr('\000a')||
'  BEGIN'||unistr('\000a')||
'  '||unistr('\000a')||
'    l_clobLen  := DBMS_LOB.GETLENGTH(p_blob);'||unistr('\000a')||
'    l_fHandler := UTL_FILE.FOPEN(P_DIRECTORY, P_FILENAME, ''wb'', 32767);'||unistr('\000a')||
'    '||unistr('\000a')||
'    LOOP'||unistr('\000a')||
'      DBMS_LOB.READ(p_blob, c_amount, l_pos, l_buffer);     '||unistr('\000a')||
'      UTL_FILE.PUT_RAW(l_fHandler, l_buffer, true);'||unistr('\000a')||
'      l_pos := l_pos + c_amount;'||unistr('\000a')||
'    END LOOP;'||unistr('\000a')||
'  '||unistr('\000a')||
'    UTL_FILE.FCLOSE(l_fHandler);'||unistr('\000a')||
'  EXCEP'||
'TION'||unistr('\000a')||
'  WHEN NO_DATA_FOUND THEN'||unistr('\000a')||
'    UTL_FILE.FCLOSE(l_fHandler);'||unistr('\000a')||
'    '||unistr('\000a')||
'  WHEN OTHERS THEN'||unistr('\000a')||
'    if utl_file.is_open(l_fHandler) then'||unistr('\000a')||
'      UTL_FILE.FCLOSE(l_fHandler);'||unistr('\000a')||
'    end if;'||unistr('\000a')||
'    '||unistr('\000a')||
'   --Log error'||unistr('\000a')||
'   raise; '||unistr('\000a')||
'  END Blob2File;'||unistr('\000a')||
'  '||unistr('\000a')||
'  function FileSizeInBytes(p_filesize varchar2)'||unistr('\000a')||
'  return integer'||unistr('\000a')||
'  as'||unistr('\000a')||
'  l_filesize varchar2(20);'||unistr('\000a')||
'  l_faktor integer default 1;'||unistr('\000a')||
'  l_posK integer default 0;'||unistr('\000a')||
'  l_posM integer d'||
'efault 0;'||unistr('\000a')||
'  l_posG integer default 0;'||unistr('\000a')||
'  l_pos integer default 0;'||unistr('\000a')||
'  l_ret number;'||unistr('\000a')||
'  begin'||unistr('\000a')||
'    if p_filesize is null then return null; end if;'||unistr('\000a')||
'    '||unistr('\000a')||
'    l_filesize := replace(upper(substr(p_filesize,1,20)),''.'','','');'||unistr('\000a')||
'    l_posK := instr(l_filesize,''K'');'||unistr('\000a')||
'    l_posM := instr(l_filesize,''M'');'||unistr('\000a')||
'    l_posG := instr(l_filesize,''G'');'||unistr('\000a')||
'  '||unistr('\000a')||
'    l_pos := least   (case l_posK when 0 then 99 else l_posK end, '||unistr('\000a')||
'      '||
'                case l_posM when 0 then 99 else l_posM end,  '||unistr('\000a')||
'                      case l_posG when 0 then 99 else l_posG end);'||unistr('\000a')||
'                      '||unistr('\000a')||
'    if l_pos = 99 then l_faktor := 1; '||unistr('\000a')||
'    elsif l_pos = l_posK then l_faktor := 1024; '||unistr('\000a')||
'    elsif l_pos = l_posM then l_faktor := 1024*1024; '||unistr('\000a')||
'    elsif l_pos = l_posG then l_faktor := 1024*1024*1024; '||unistr('\000a')||
'    end if;'||unistr('\000a')||
'    '||unistr('\000a')||
'    if l_pos > 0 then '||unistr('\000a')||
'      l'||
'_ret := to_number(trim(substr(l_filesize, 1,l_pos-1)));'||unistr('\000a')||
'      l_ret := l_ret * l_faktor;'||unistr('\000a')||
'    else'||unistr('\000a')||
'      l_ret := to_number(l_filesize);'||unistr('\000a')||
'    end if;'||unistr('\000a')||
'    return trunc(l_ret);'||unistr('\000a')||
'    exception    '||unistr('\000a')||
'      when others then  '||unistr('\000a')||
'      --Error loging'||unistr('\000a')||
'       return null;'||unistr('\000a')||
'  end FileSizeInBytes;'||unistr('\000a')||
''||unistr('\000a')||
'  function GetFileType('||unistr('\000a')||
'    P_FILENAME VARCHAR2'||unistr('\000a')||
'  )'||unistr('\000a')||
'  return varchar2'||unistr('\000a')||
'  AS'||unistr('\000a')||
'  l_ret varchar2(20);'||unistr('\000a')||
'  l_pos number;'||unistr('\000a')||
'  BEGI'||
'N'||unistr('\000a')||
'  '||unistr('\000a')||
'    l_pos := INSTR(P_FILENAME, ''.'', -1, 1);'||unistr('\000a')||
'    if l_pos > 0 then'||unistr('\000a')||
'      l_ret := lower(SUBSTR(P_FILENAME, l_pos + 1)); '||unistr('\000a')||
'    end if;'||unistr('\000a')||
'    '||unistr('\000a')||
'    return l_ret;'||unistr('\000a')||
'  end;'||unistr('\000a')||
'  '||unistr('\000a')||
'  function ChangeFileType (p_filename varchar2 , p_filetype varchar2)'||unistr('\000a')||
'  return varchar2'||unistr('\000a')||
'  as'||unistr('\000a')||
'  l_point_position number;'||unistr('\000a')||
'  begin'||unistr('\000a')||
'    l_point_position := INSTR(p_filename, ''.'', -1, 1);'||unistr('\000a')||
'    if p_filetype is null then'||unistr('\000a')||
'      if l_point'||
'_position > 1 then '||unistr('\000a')||
'        return substr(p_filename, 1, l_point_position-1);'||unistr('\000a')||
'      end if;'||unistr('\000a')||
'    else'||unistr('\000a')||
'      if l_point_position = 0 then '||unistr('\000a')||
'        return p_filename||''.''||p_filetype;'||unistr('\000a')||
'      else'||unistr('\000a')||
'        return SUBSTR(p_filename, 1,INSTR(p_filename, ''.'', -1, 1))||p_filetype;'||unistr('\000a')||
'      end if;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
'    return p_filename; --without filetype before and now'||unistr('\000a')||
'  end;'||unistr('\000a')||
''||unistr('\000a')||
'  begin'||unistr('\000a')||
'    '||unistr('\000a')||
'    l_filebrowse := V(p_'||
'process.attribute_01);'||unistr('\000a')||
'    l_dbdirectory:= p_process.attribute_02;'||unistr('\000a')||
'    l_filename:= p_process.attribute_03;'||unistr('\000a')||
'    l_max_file_size:= FileSizeInBytes(p_process.attribute_04);'||unistr('\000a')||
'    l_filename_item := p_process.attribute_05;'||unistr('\000a')||
'    l_hash_item:= p_process.attribute_06;'||unistr('\000a')||
'   '||unistr('\000a')||
'     if l_filebrowse is null then  --do nothing when submit   '||unistr('\000a')||
'      return l_ret;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
'    '||unistr('\000a')||
'    select count(*) into l_filebrows'||
'e_ok '||unistr('\000a')||
'    from apex_application_page_items '||unistr('\000a')||
'    where display_as_code = ''NATIVE_FILE'' '||unistr('\000a')||
'    and attribute_01 = ''WWV_FLOW_FILES'' '||unistr('\000a')||
'    and application_id = V(''APP_ID'')'||unistr('\000a')||
'    and page_id = V(''APP_PAGE_ID'') '||unistr('\000a')||
'    and item_name = p_process.attribute_01;'||unistr('\000a')||
'    '||unistr('\000a')||
'    if l_filebrowse_ok <> 1 then'||unistr('\000a')||
'      l_ret.success_message := ''Item ''||p_process.attribute_01||'' is not File Browse item or dosen''''t have defined WW'||
'V_FLOW_FILES for storage.'';'||unistr('\000a')||
'      return l_ret;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
'    '||unistr('\000a')||
'    select blob_content, doc_size '||unistr('\000a')||
'    into l_blob, l_doc_size '||unistr('\000a')||
'    from wwv_flow_files where name = l_filebrowse;'||unistr('\000a')||
'    '||unistr('\000a')||
'    if l_doc_size > l_max_file_size then'||unistr('\000a')||
'      l_ret.success_message := ''File size too big. Maximum allowed size is ''||l_max_file_size||'' bytes.'';'||unistr('\000a')||
'      delete from wwv_flow_files where name = l_filebrowse;'||unistr('\000a')||
'    else'||
''||unistr('\000a')||
'      l_filename := ChangeFileType(l_filename, GetFileType(l_filebrowse));--change file type to uploaded filetype'||unistr('\000a')||
''||unistr('\000a')||
'      if l_hash_item is not null then'||unistr('\000a')||
'        apex_util.set_session_state(l_hash_item, DBMS_CRYPTO.Hash(l_blob, DBMS_CRYPTO.HASH_SH1));'||unistr('\000a')||
'      end if;'||unistr('\000a')||
''||unistr('\000a')||
'      Blob2File(l_dbdirectory, l_filename, l_blob);'||unistr('\000a')||
'      delete from wwv_flow_files where name = l_filebrowse;'||unistr('\000a')||
'      if l_filename_i'||
'tem is not null then'||unistr('\000a')||
'        apex_util.set_session_state(l_filename_item, l_filename);'||unistr('\000a')||
'      end if;'||unistr('\000a')||
''||unistr('\000a')||
'      l_ret.success_message := p_process.success_message;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
'    commit;'||unistr('\000a')||
'    return l_ret;'||unistr('\000a')||
'exception    '||unistr('\000a')||
'    when others then  '||unistr('\000a')||
'    l_ret.success_message := ''Error when moving file ''||l_filebrowse||'' from WWV_FLOW_FILES table to server disk ''||'||unistr('\000a')||
'                             ''on location (O'||
'racle DB directory) ''||l_dbdirectory||''\\''||l_filename||'' . SQLERR: ''||sqlerrm;  '||unistr('\000a')||
'    --log error'||unistr('\000a')||
''||unistr('\000a')||
'                  '||unistr('\000a')||
'    return l_ret;'||unistr('\000a')||
'    rollback;'||unistr('\000a')||
'  END SaveToDisk;'
 ,p_execution_function => 'SaveToDisk'
 ,p_substitute_attributes => true
 ,p_subscribe_plugin_settings => true
 ,p_help_text => '<p>'||unistr('\000a')||
'	Process plugin moves uploaded file from WWV_FLOW_FILES table to server disk. Process deletes row from WWV_FLOW_FILES.</p>'||unistr('\000a')||
''
 ,p_version_identifier => '1.0'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 216389846385311130 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 254910161854139662 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 1
 ,p_display_sequence => 10
 ,p_prompt => 'File Browse Item'
 ,p_attribute_type => 'PAGE ITEM'
 ,p_is_required => true
 ,p_is_translatable => false
 ,p_help_text => 'Name of File Browse item (e.g. P1_UPLOAD) which holds filename of uploaded file you want to move from WWV_FLOW_FILES to server disk.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 254968440964275572 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 254910161854139662 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 2
 ,p_display_sequence => 20
 ,p_prompt => 'Database directory'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => true
 ,p_display_length => 50
 ,p_max_length => 100
 ,p_is_translatable => false
 ,p_help_text => 'Database directory where you want to move uploaded file.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 254972871616322233 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 254910161854139662 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 3
 ,p_display_sequence => 30
 ,p_prompt => 'Filename'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => true
 ,p_display_length => 50
 ,p_max_length => 100
 ,p_is_translatable => false
 ,p_help_text => 'Destination filename.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 254977258335384676 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 254910161854139662 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 4
 ,p_display_sequence => 40
 ,p_prompt => 'Max Filesize'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => false
 ,p_display_length => 25
 ,p_max_length => 25
 ,p_is_translatable => false
 ,p_help_text => 'Maximum allowed size in bytes. Abrreviations K,KB,M,MB,G,GB are allowed. Examples of valid formats: 100000, 150 K, 3,76 M, 1,5 GB, 1.5G. '
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 178097326666886070 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 254910161854139662 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 5
 ,p_display_sequence => 50
 ,p_prompt => 'Item with Filename'
 ,p_attribute_type => 'PAGE ITEM'
 ,p_is_required => false
 ,p_is_translatable => false
 ,p_help_text => 'Select page item which will save filename of uploaded file. Usually you want to use this item value in process after SaveToDisk process.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 2476323678306086 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 254910161854139662 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 6
 ,p_display_sequence => 60
 ,p_prompt => 'Item with Hash value'
 ,p_attribute_type => 'PAGE ITEM'
 ,p_is_required => false
 ,p_is_translatable => false
 ,p_help_text => 'Select page item to store Hash value of type RAW. This is useful when you want to track file changes.'
  );
null;
 
end;
/

commit;
begin
execute immediate 'begin sys.dbms_session.set_nls( param => ''NLS_NUMERIC_CHARACTERS'', value => '''''''' || replace(wwv_flow_api.g_nls_numeric_chars,'''''''','''''''''''') || ''''''''); end;';
end;
/
set verify on
set feedback on
set define on
prompt  ...done
