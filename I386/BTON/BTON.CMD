ChkAWMIACPISrv.exe -i
TurnBTOn.exe
ChkAWMIACPISrv.exe -u

rd /s /q C:\WIMAPPLY

Find /i "W7GPT" C:\Windows\AsToolCDVer.txt
if %errorlevel%==0 (ForceIRST.exe /ForceSetIRST)
