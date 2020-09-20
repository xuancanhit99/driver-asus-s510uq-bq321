@echo off

set _CUR_PATH="%~dp0%"


if defined ProgramFiles(x86) (

set _REPLACE_PATH="C:\Program Files (x86)\ASUS\ASUS Smart Gesture\AsTPCenter"
    
) else (

set _REPLACE_PATH="C:\Program Files\ASUS\ASUS Smart Gesture\AsTPCenter"

)

pushd %_CUR_PATH%

rem call Disable3Fun.exe
msiexec /qn /norestart /x {938CFBD4-0652-49E5-BB8B-153948865941}
msiexec /qn /norestart /i "%~dp0%SetupTPDriver.msi" 

echo Copy Files From update Directory
if exist %_REPLACE_PATH% XCOPY .\update %_REPLACE_PATH% /S /Y /R

popd