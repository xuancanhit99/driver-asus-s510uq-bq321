set DPTFPath=C:\Windows\ASUS\DPTF

if exist %DPTFPath%\dptf.dv (
mkdir C:\Windows\ServiceProfiles\LocalService\AppData\Local\Intel\DPTF
copy /y %DPTFPath%\dptf.dv C:\Windows\ServiceProfiles\LocalService\AppData\Local\Intel\DPTF
)
