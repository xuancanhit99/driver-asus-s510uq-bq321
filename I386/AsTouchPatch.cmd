@echo off
rem Enhance 

Set LogFile=c:\Windows\Log\TouchDetectResult.log

if exist "C:\Preload\Patch" (
set RootPath=C:\Preload\Patch
set PatchFile=AsPatchTouchPanel.exe
)
if exist "C:\Preload64\Patch" (
set RootPath=C:\Preload64\Patch
set PatchFile=AsPatchTouchPanel64.exe
)
goto Patch

:Patch
if exist %RootPath%\AsTouchPanel\AsTouchDetect.exe start /w %RootPath%\AsTouchPanel\AsTouchDetect.exe
if %ERRORLEVEL%==1 (
mkdir C:\ProgramData\AsTouchPanel
copy /y %RootPath%\AsTouchPanel\%PatchFile% C:\ProgramData\AsTouchPanel
copy /y %RootPath%\AsTouchPanel\AsPatchTouchPanel.ini C:\ProgramData\AsTouchPanel
start /w C:\ProgramData\AsTouchPanel\%PatchFile% /s
echo Function Enable >> %LogFile%
goto End
)
echo Function Disable >> %LogFile%
goto End

:End
