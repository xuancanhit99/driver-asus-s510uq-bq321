rd /s /q C:\WIMAPPLY

if exist "C:\Preload\Patch" set RootPath=C:\Preload\Patch
if exist "C:\Preload64\Patch" set RootPath=C:\Preload64\Patch

if exist %RootPath%\OEM\AsPowerCfg.exe call %RootPath%\OEM\AsPowerCfg.exe /s
if exist %RootPath%\AsDCDInst.cmd call %RootPath%\AsDCDInst.cmd
if exist %RootPath%\AsHDIInst.cmd call %RootPath%\AsHDIInst.cmd
rem if exist %RootPath%\chklogo.cmd call %RootPath%\chklogo.cmd
if exist %RootPath%\WinSat.cmd call %RootPath%\WinSat.cmd
if exist %RootPath%\AsTouchPatch.cmd call %RootPath%\AsTouchPatch.cmd
