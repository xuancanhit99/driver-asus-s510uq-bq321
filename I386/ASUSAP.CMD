rd /s /q C:\WIMAPPLY

if exist "C:\Preload\Patch" set RootPath=C:\Preload\Patch
if exist "C:\Preload64\Patch" set RootPath=C:\Preload64\Patch

if exist %RootPath%\AsPreDCDInst.cmd call %RootPath%\AsPreDCDInst.cmd
%RootPath%\AsusService.exe -i
sc start AsusService
start %RootPath%\AsInst.exe /inst
