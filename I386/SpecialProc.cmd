if exist "C:\Preload\Patch" set RootPath=C:\Preload\Patch
if exist "C:\Preload64\Patch" set RootPath=C:\Preload64\Patch
set LogPath=C:\Windows\Log

find /i "MS" c:\Windows\AsHDIVer.txt 
if %ERRORLEVEL%==0 goto Case_MS
goto End


:Case_MS
echo Signature case be selected > %LogPath%\SpecialProc.Log
if exist %RootPath%\AsSetUnattend.exe call %RootPath%\AsSetUnattend.exe /DeviceForm
goto End


:End