
declare @filePath NVARCHAR(max) = 'C:\GitHub\botDevJustinPope\working-docs\random code\TEST_PATH\test.txt',
	    @content NVARCHAR(max) = 'this is a test',
		@cmd VARCHAR(8000) = '';

set @cmd = 'powershell.exe -File "C:\GitHub\botDevJustinPope\working-docs\random code\PowerShell\WriteToFile.ps1" -filePath "' + @filePath + '" -content "' + @content + '"';
exec xp_cmdshell @cmd;