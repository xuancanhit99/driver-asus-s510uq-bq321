@echo off

echo [%date% %time:~0,8%]	==========	ChkDevice	========== >> %SystemRoot%\Log\DevChkResult.log

if exist "C:\Preload\Patch" (
set RootPath=C:\Preload\Patch
set USMTPath=C:\Preload
set OSType=
)
if exist "C:\Preload64\Patch" (
set RootPath=C:\Preload64\Patch
set USMTPath=C:\Preload64
set OSType=64
)

set ReturnCode=1

call %RootPath%\devcon.exe status * > %SystemRoot%\log\devlist.txt

if exist C:\Windows\log\PR.log (
echo [%date% %time:~0,8%]	PR >> %SystemRoot%\Log\DevChkResult.log
goto EXIT
)

FINDSTR /IRC:"problem" %SystemRoot%\log\devlist.txt
if %ERRORLEVEL%==0 (
echo [%date% %time:~0,8%]	Error_Device >> %SystemRoot%\log\DevChkResult.log
set ReturnCode=0
)

FINDSTR /IRC:"unknown" %SystemRoot%\log\devlist.txt
if %ERRORLEVEL%==0 (
echo [%date% %time:~0,8%]	Error_Unknown >> %SystemRoot%\log\DevChkResult.log
set ReturnCode=0
)

:EXIT

echo [%date% %time:~0,8%]	==========	ChkDevice	========== >> %SystemRoot%\Log\DevChkResult.log

echo. >> %SystemRoot%\Log\DevChkResult.log

::EXIT /B %ReturnCode%

if %ReturnCode%==0 (
taskkill /F /IM AsInst.exe
call %RootPath%\SERROR.exe Check Device List Failed !!
)
