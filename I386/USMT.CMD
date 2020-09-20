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

mkdir C:\Recovery\Customizations
move /y %RootPath%\ScanState\*.* %USMTPath%\

set /a Count=0
set USMTErrCode=-1

:Start_USMT
If %USMTErrCode%==0 goto End_USMT
If %Count%==5 goto End_USMT
set /a Count=Count+1

taskkill /F /IM WerFault.exe
taskkill /F /IM ScanState.exe
timeout /t 20

call %USMTPath%\ScanState.exe /apps /ppkg C:\Recovery\Customizations\usmt.ppkg /o /c /v:13 /l:C:\Windows\Log\ScanState%Count%.log /i:%RootPath%\MigConfig.xml /config:%RootPath%\WRConfig.xml
set USMTErrCode=%errorlevel%
echo %date% %time:~0,8% USMTErrCode : %USMTErrCode% >> C:\Windows\Log\ScanState%Count%.log
goto Start_USMT

:End_USMT
if %USMTErrCode% neq 0 goto Err
timeout /t 3
goto End

:Err
taskkill /F /IM AsInst.exe
call %RootPath%\SERROR.exe USMT Process Fail , ErrorCode : %USMTErrCode%

:End
