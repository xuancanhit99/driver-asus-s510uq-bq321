set RDXSrcPath=C:\Windows\ASUS\RDX
set LogPath=C:\Windows\Log

find /i "T1" c:\Windows\AsHDIVer.txt 
if %ERRORLEVEL%==0 goto Case_BBY
find /i "MS" c:\Windows\AsHDIVer.txt 
if %ERRORLEVEL%==0 goto Case_MS
goto Case_Channel

:Case_BBY
echo BBY case be selected > %LogPath%\RDX.Log
rd /s /q %RDXSrcPath%\Signature
rd /s /q %RDXSrcPath%\Channel
move /y %RDXSrcPath%\copyrdx.cmd %RDXSrcPath%\BBY
pushd %RDXSrcPath%\BBY
copyrdx.cmd en-us
popd

goto End

:Case_MS
echo Signature case be selected > %LogPath%\RDX.Log
rd /s /q %RDXSrcPath%\BBY
rd /s /q %RDXSrcPath%\Channel
move /y %RDXSrcPath%\copyrdx.cmd %RDXSrcPath%\Signature
pushd %RDXSrcPath%\Signature
copyrdx.cmd en-us
popd

goto End

:Case_Channel
echo Channel case be selected > %LogPath%\RDX.Log
rd /s /q %RDXSrcPath%\BBY
rd /s /q %RDXSrcPath%\Signature
move /y %RDXSrcPath%\copyrdx.cmd %RDXSrcPath%\Channel
pushd %RDXSrcPath%\Channel
copyrdx.cmd en-us
popd

goto End

:End