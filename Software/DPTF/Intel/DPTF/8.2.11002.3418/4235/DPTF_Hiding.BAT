start /w setup.exe -s
start /w Reg.exe ADD HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\48df9d60-4f68-11dc-8314-0800200c9a66 /v Attributes /t REG_DWORD /d 1 /f
exit
