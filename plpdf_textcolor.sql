CREATE OR REPLACE procedure textcolor is
    /* 12. Example: Set text color */
    
  l_blob blob;
 begin
   
    /* Initialize, without parameters means: 
     - page orientation: portrait
     - unit: mm
     - default page format: A4 */
    plpdf.init; 
    
    /* Begin a new page, without parameters means: 
     - page orientation: default (portrait) */
    plpdf.NewPage; 
    
    /* Sets the font and its properties */
    plpdf.SetPrintFont(
     p_family => 'Arial',  -- Font family: Arial
     p_style => null,      -- Font style: regular (default)
     p_size => 12          -- Font size: 12 pt
     ); 
	
    /* Sets the text color for objects inserted after this statement. 
       Colors must be specified according to the RGB pallet. */
    plpdf.SetColor4Text(
     p_r => 220,           -- Red component code, can be between 0 and 255
     p_g => 50,            -- Green component code, can be between 0 and 255
     p_b => 50             -- Blue component code, can be between 0 and 255
     );	
     
     /* Draws a rectangle cell with text inside. 
        The rectangle may have a border and fill color specified. */
    plpdf.PrintCell(
     p_w => 50,             -- Rectangle width
     p_h => 10,             -- Rectangle heigth
     p_txt => 'Color text1' -- Text in rectangle 
     ); 
	
    /* Line break. 
       Cursor is placed at the start of the next line.*/
    plpdf.LineBreak(
     p_h => 20              -- Height of the line break.
     );
	
    /* Sets the text color for objects inserted after this statement. 
       Colors must be specified according to the RGB pallet. 
     - p_g: -1 (default)
     - p_b: -1 (default) */
    plpdf.SetColor4Text(
     p_r => 0               -- Red component code: 0 (black)
     );                     
	
    /* Draws a rectangle cell with text inside. 
       The rectangle may have a border and fill color specified. */
    plpdf.PrintCell(
     p_w => 50,             -- Rectangle width
     p_h => 10,             -- Rectangle heigth
     p_txt => 'Color text2' -- Text in rectangle 
     ); 
    
    /* Returns the generated PDF document. 
       The document is closed and then returned in the OUT parameter. */
    plpdf.SendDoc(
     p_blob => l_blob      -- The generated document
     );
    
    
    /* Print it:
    
	owa_util.mime_header('application/pdf',false);
        htp.p('Content-Length: ' || dbms_lob.getlength(l_blob)); 
        owa_util.http_header_close; 	
        wpg_docload.download_file(l_blob);   */
    
    /* Store */
    insert into STORE_BLOB (blob_file, created_date) values (l_blob, sysdate);
    
    commit;
 end;
/

