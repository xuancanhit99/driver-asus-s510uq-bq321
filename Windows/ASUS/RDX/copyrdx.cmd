@echo off
setlocal

set EXITCODE=0

rem
rem Input validation
rem
if /i "%1"=="/?" goto usage
if /i "%1"=="" goto usage
if /i not "%2"=="" goto usage
if /i not "%3"=="" goto usage

rem
rem Set environment variables for use in the script
rem
set DEFAULT_NEU=%1
set SOURCE=%~dp0
set DEST=%programdata%\Microsoft\Windows\RetailDemo\OfflineContent\OEM\Content
set DEST_TEMPL=HubContent
set DEST_NEU=%DEST%\Neutral\%DEST_TEMPL%
set DEST_NEU_WMV=%DEST%\Neutral\AttractContent\Microsoft.BasicAttractLoop_8wekyb3d8bbwe


rem
rem Validate input architecture
rem
rem If the source directory as per input architecture does not exist,
rem it means the architecture is not present
rem
if not exist "%SOURCE%%DEFAULT_NEU%" (
  echo ERROR: The following default neutral folder was not found: %DEFAULT_NEU%.
  goto fail
)

if not exist "%SOURCE%%DEFAULT_NEU%\OEM.json" (
  echo ERROR: The following default neutral OEM.json was not found: %DEFAULT_NEU%\OEM.json.
  goto fail
)

if not exist "%SOURCE%%DEFAULT_NEU%\OEM.zip" (
  echo ERROR: The following default neutral OEM.json was not found: %DEFAULT_NEU%\OEM.zip.
  goto fail
)

if not exist "%SOURCE%Neutral\attract.wmv" (
  echo ERROR: The following Neutral attract.wmv was not found: Neutral\attract.wmv.
  goto fail
)


echo.
echo ===================================================
echo Creating RDX customization working directory
echo.
echo     %DEST%
echo ===================================================
echo.

mkdir "%DEST_NEU%"
if errorlevel 1 (
  echo ERROR: Unable to create directory: "%DEST_NEU%".
  goto fail
)

mkdir "%DEST_NEU_WMV%"
if errorlevel 1 (
  echo ERROR: Unable to create directory: "%DEST_NEU_WMV%".
  goto fail
)

for /f %%i in ('dir /ad /b %~dp0') do (
  echo.%%i
  if /I not "%%i" == "Neutral" (
    mkdir "%DEST%\%%i\%DEST_TEMPL%"
    if errorlevel 1 (
      echo ERROR: Unable to create directory: "%DEST%\%%i\%DEST_TEMPL%".
      goto fail
    )
  )
)

rem
rem Copy the boot files and WinPE WIM to the destination location
rem
xcopy /herky "%SOURCE%Neutral" "%DEST_NEU_WMV%\"
if errorlevel 1 (
  echo ERROR: Unable to copy vedio files: "%SOURCE%Neutral" to "%DEST_NEU_WMV%".
  goto fail
)

xcopy /herky "%SOURCE%%DEFAULT_NEU%" "%DEST_NEU%\"
if errorlevel 1 (
  echo ERROR: Unable to copy Neutral files: "%SOURCE%%DEFAULT_NEU%" to "%DEST_NEU%".
  goto fail
)

for /f %%i in ('dir /ad /b %~dp0') do (
  echo.%%i
  if /I not "%%i" == "Neutral" (
    xcopy /herky "%SOURCE%%%i" "%DEST%\%%i\%DEST_TEMPL%"
    if errorlevel 1 (
      echo Unable to copy Neutral files: "%SOURCE%%%i"" to "%DEST%\%%i\%DEST_TEMPL%".
      goto fail
    )
  )
)

:success
set EXITCODE=0
echo.
echo Success
echo.
goto cleanup

:usage
set EXITCODE=1
echo Creates working directories for RDX customization.
echo.
echo copyrdx { en-us ^| ja-jp ^| zh-cn }
echo.
echo  en-us             Copies en-us OEM files and video to ^<workingDirectory^>.
echo  ja-jp             Copies ja-jp OEM files and video to ^<workingDirectory^>.
echo  zh-cn             Copies zh-cn OEM files and video to ^<workingDirectory^>.
echo  [others]          Copies WANTED OEM files and video to ^<workingDirectory^>.
echo                    Note: The Video may be present in this Neutral folder.
echo                          ^<workingDirectory^> is RDX specified location.
echo.
echo Example: copyrdx en-us
goto cleanup

:fail
set EXITCODE=1
echo Failed!
goto cleanup

:cleanup
endlocal & exit /b %EXITCODE%
