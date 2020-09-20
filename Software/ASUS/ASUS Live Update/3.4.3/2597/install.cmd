mkdir c:\Windows\ASUS\oobeEula

move /y %~dp0ASUSLiveUpdate c:\Windows\ASUS\oobeEula

call Setup.exe /qn /norestart