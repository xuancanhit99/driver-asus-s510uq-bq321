rd /s /q C:\WIMAPPLY

set SmartPinPath=C:\Windows\ASUS\TilesData

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

if exist %RootPath%\As601Inst.cmd call %RootPath%\As601Inst.cmd

if exist %RootPath%\AsStageIntegrate.exe call %RootPath%\AsStageIntegrate.exe /ContactSupp
if exist %RootPath%\AsSetUnattend.exe call %RootPath%\AsSetUnattend.exe /TrustedImageIdentifier
if exist %RootPath%\AsInsEula.exe call %RootPath%\AsInsEula.exe
if exist %RootPath%\AsInsXml.exe call %RootPath%\AsInsXml.exe
if exist %RootPath%\AsHIDPairing\AsHIDPairing.exe call %RootPath%\AsHIDPairing\AsHIDPairing.exe
if exist %RootPath%\AsPinTaskBar\AsPinTaskBar%OSType%.exe call %RootPath%\AsPinTaskBar\AsPinTaskBar%OSType%.exe
if exist %SmartPinPath%\AsSmartPin.exe call %SmartPinPath%\AsSmartPin.exe
if exist %RootPath%\AsOfficeRTC.exe call %RootPath%\AsOfficeRTC.exe
if exist %RootPath%\BBY.jpg copy /y %RootPath%\BBY.jpg c:\Windows\ASUS\wallpapers\ASUS.JPG

del /q C:\*setup.*
del /q C:\ASUS*.md5
del /q C:\*.txt
del /q C:\*.log
del /q C:\*.iss
del /q C:\*.bak
rd /s /q C:\Sources
rd /s /q C:\Temp

echo Finish >> C:\Windows\log\Finish.log
::%RootPath%\devcon.exe status * > C:\Windows\log\devlist.txt
if exist %RootPath%\ChkDevice.cmd call %RootPath%\ChkDevice.cmd

attrib +h c:\PerfLogs
attrib +h c:\Intel
attrib +h c:\*.*

if exist c:\Windows\log\CleanDT.log del /q c:\users\public\Desktop\*.*
if exist c:\Windows\log\CleanDT.log del /q c:\Windows\asus\shortcuts\*.lnk

call reg.exe add "HKLM\Software\microsoft\Windows\CurrentVersion\Setup\OOBE" /v SetupDisplayedProductKey /t REG_DWORD /d 1 /f /reg:64
call reg.exe delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ClipSVC\Parameters /v ProcessBiosKey /f /reg:64

%RootPath%\AsusService.exe -r
taskkill /F /IM sysprep.exe /T
call net start TrustedInstaller
timeout /t 10
call net start TrustedInstaller

if exist %RootPath%\USMT.cmd call %RootPath%\USMT.cmd

if exist %RootPath%\SetOEM.cmd call %RootPath%\SetOEM.cmd

if exist %RootPath%\OAReport.cmd call %RootPath%\OAReport.cmd
if exist %RootPath%\machineinfo.cmd call %RootPath%\machineinfo.cmd
if exist %RootPath%\CBR.xml copy /y %RootPath%\CBR.xml c:\Windows\Log\CBR.xml
if exist %RootPath%\machineinfo-output.txt copy /y %RootPath%\machineinfo-output.txt c:\Windows\Log\machineinfo-output.txt
if exist %RootPath%\OATrace.log copy /y %RootPath%\OATrace.log c:\Windows\Log\OATrace.log

if exist %RootPath%\AsStageIntegrate.exe call %RootPath%\AsStageIntegrate.exe /CopyOA3

call %RootPath%\BOOTOPE.CMD

copy /y C:\Windows\log\devlist.txt C:\
copy /y C:\Windows\log\Finish.log C:\
attrib +h c:\*.*
if exist %RootPath%\OEM\AsPowerCfg.exe call %RootPath%\OEM\AsPowerCfg.exe /r
if exist %RootPath%\As601InstEnd.cmd call %RootPath%\As601InstEnd.cmd
call c:\windows\system32\sysprep\sysprep.exe -oobe -quiet -quit

call reg.exe add "HKLM\Software\microsoft\Windows\CurrentVersion\Setup\OOBE" /v SetupDisplayedProductKey /t REG_DWORD /d 1 /f /reg:64
call reg.exe delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ClipSVC\Parameters /v ProcessBiosKey /f /reg:64
call shutdown /r /t 0