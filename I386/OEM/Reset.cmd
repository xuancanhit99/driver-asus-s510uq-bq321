for %%A in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO (
if exist %%A:\Recovery\OEM\ResetConfig.xml SET TARGETOSDRIVE=%%A:
)

if exist "%TARGETOSDRIVE%\Program Files (x86)" SET OSType=64
if not exist "%TARGETOSDRIVE%\Program Files (x86)" SET OSType=

set RootPath=%TARGETOSDRIVE%\Recovery\OEM
set LMXmlPath=%TARGETOSDRIVE%\Users\Default\AppData\Local\Microsoft\Windows\Shell

copy /y %RootPath%\Unattend.xml %TARGETOSDRIVE%\Windows\panther
xcopy /cherky %RootPath%\Info %TARGETOSDRIVE%\Windows\System32\OOBE\info\

rem LayoutModify
copy /y %RootPath%\LayoutModification.xml %LMXmlPath%

rem Pin Taskbar Icon
rem if exist %RootPath%\AsPinTaskBar\AsPinTaskBar%OSType%.exe call %RootPath%\AsPinTaskBar\AsPinTaskBar%OSType%.exe RESET

rem Restore Desktop Icon
copy /y %TARGETOSDRIVE%\Windows\ASUS\Shortcuts\*.lnk %TARGETOSDRIVE%\Users\Public\Desktop\    

rem OOBEClear.cmd
del /s /q "%TARGETOSDRIVE%\Users\Public\Desktop\Media Player Center.lnk"
del /s /q "%TARGETOSDRIVE%\Users\Public\Desktop\Messenger Center.lnk"
del /s /q "%TARGETOSDRIVE%\ProgramData\Microsoft\Windows\Start Menu\Programs\Media Player Center.lnk"
del /s /q "%TARGETOSDRIVE%\ProgramData\Microsoft\Windows\Start Menu\Programs\Messenger Center.lnk"

rem OOBEIns.cmd
if not exist %TARGETOSDRIVE%\Windows\ASUS\OOBEProc md %TARGETOSDRIVE%\Windows\ASUS\OOBEProc
echo if exist C:\PerfLogs attrib +h C:\PerfLogs >> %TARGETOSDRIVE%\Windows\ASUS\OOBEProc\OOBEIns.cmd
echo if exist C:\Intel attrib +h C:\Intel >> %TARGETOSDRIVE%\Windows\ASUS\OOBEProc\OOBEIns.cmd
echo call C:\Recovery\OEM\AsPowerCfg.exe /r >> %TARGETOSDRIVE%\Windows\ASUS\OOBEProc\OOBEIns.cmd

rem Fix PC becomes sluggish
REG LOAD HKLM\TempReg "%TARGETOSDRIVE%\Windows\System32\config\SOFTWARE"
REG ADD "HKLM\TempReg\Microsoft\Windows Search" /v RebuildIndex /t REG_DWORD /d 7 /f
REG UNLOAD HKLM\TempReg