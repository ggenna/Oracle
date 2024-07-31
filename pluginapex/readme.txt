Contens of ZIP file:
process_type_plugin_si_mirmas_savetodisk.sql - plugin file
SaveToDisk.sql - plugin interface suorce
f102.sql - demo application for this plugin and FileDownloadLink item plugin


Create directory on server file system (e.g. create or replace directory TESTDIR as 'c:\testdir')
Grant read, write privileges on directory (e.g. grant READ, WRITE on directory "TESTDIR" to <user>);
login as SYS as SYSDBA
grant EXECUTE on "SYS"."UTL_FILE" to <user> ;

Install plugin.
Create File Browse page item and choose WWV_FLOW_FILES for storage.
Create process of type plugin.
Choose process Point: On Submit - After Computations and Validations (default)

File Browse Item: Name of File Browse item (e.g. P1_UPLOAD) which holds filename of uploaded file 
you want to move from WWV_FLOW_FILES table to server disk.

Database directory: Database directory where you want to move uploaded file.

Filename: Destination filename.

Max Filesize: Maximum allowed size in bytes. Abrreviations K,KB,M,MB,G,GB are allowed. 
Examples of valid formats: 100000, 150 K, 3,76 M, 1,5 GB, 1.5G. 

Item with Filename: Select page item which will save filename of uploaded file. 
Usually you want to use this item value in process after SaveToDisk process.

Item with Hash value: Select page item to store Hash value of type RAW. This is useful when you want to track file changes.

Conditions: Select Condition Type "Value od Item/Column in Expression Is NOT NULL" and for Expression1 
set the same File Browse item you set at Plug-in settings (e.g. P1_UPLOAD). This step is optional. 

For the rest you can left defaults.