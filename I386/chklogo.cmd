if exist C:\Windows\log\PR.log goto End

if exist "C:\Preload\Patch" (
set RootPath=C:\Preload\Patch
set OSType=32
)
if exist "C:\Preload64\Patch" (
set RootPath=C:\Preload64\Patch
set OSType=64
)

goto chklogo

:chklogo
start /w %RootPath%\CheckLogo\%OSType%\CheckLogo.exe /checklogo /results C:\Windows\Log\
goto VerifyLog

:VerifyLog
find /i "D" C:\Windows\Log\CheckCertification_failedlist.txt 
if %ERRORLEVEL%==0 goto ChkFail
goto End

:ChkFail
taskkill /F /IM AsInst.exe
goto Error

:Error
start /w %RootPath%\SERROR.exe ECHO Check Logo Failed (ERROR) !!
pause
goto End

:End
