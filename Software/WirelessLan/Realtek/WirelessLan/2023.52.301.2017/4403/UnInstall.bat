@ECHO OFF

set ISSPath=%CD%\Uninstall_ISS_1.00.iss
"%ProgramFiles(x86)%\InstallShield Installation Information\{9DAABC60-A5EF-41FF-B2B9-17329590CD5}\setup.exe" -uninst -s -f1"%ISSPath%" -f2"c:\setup_1.00.log"

set RootPath=%CD%\Uninstall.iss
setup.exe -UNINST -removeonly -s /f1"%RootPath%" /f2"c:\setup.log"
