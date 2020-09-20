rd /s /q C:\WIMAPPLY

if exist "C:\Preload\Patch" (
set RootPath=C:\Preload\Patch
)
if exist "C:\Preload64\Patch" (
set RootPath=C:\Preload64\Patch
)

set LMXmlPath=%SYSTEMDRIVE%\Users\Default\AppData\Local\Microsoft\Windows\Shell

if not exist %RootPath%\OEM\Info md %RootPath%\OEM\Info
copy /y C:\Windows\Panther\unattend.xml %RootPath%\OEM 

rem xcopy /cherky %RootPath%\AsPinTaskBar %RootPath%\OEM\AsPinTaskBar\

xcopy /cherky C:\Windows\System32\OOBE\info %RootPath%\OEM\Info\

copy /y %LMXmlPath%\LayoutModification.xml %RootPath%\OEM

xcopy /cherky %RootPath%\OEM C:\Recovery\OEM\


