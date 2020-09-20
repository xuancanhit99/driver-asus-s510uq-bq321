rd /s /q C:\WIMAPPLY

if exist "C:\Preload\Patch" set RootPath=C:\Preload\Patch
if exist "C:\Preload64\Patch" set RootPath=C:\Preload64\Patch

if exist %RootPath%\ahci.reg call Reg.exe IMPORT %RootPath%\ahci.reg

if exist %RootPath%\As600Inst.cmd call %RootPath%\As600Inst.cmd
rem RDX
if exist %RootPath%\RDX.cmd call %RootPath%\RDX.cmd

rem Remove File For Special Image Case
if exist %RootPath%\SpecialProc.cmd call %RootPath%\SpecialProc.cmd

rem Config 
if exist %RootPath%\ASUSConfig.cmd call %RootPath%\ASUSConfig.cmd
