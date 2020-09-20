@echo off

SETLOCAL

rem
rem Modify this to provide useful output file name if necessary
rem

set SUFFIX=%COMPUTERNAME%-%DATE:/=%-%TIME::=-%
set SUFFIX=output
set OUTFILE=".\machineinfo-%suffix%.txt"

rem
rem Override the default name if it is specified as input parameter
rem

if NOT {%1} == {} (
    set OUTFILE=%1
)

rem
rem Do not change this value
rem

set FILEFORMATVERSION=20120803-100003

rem
rem Run the same file with UNICODE output to match the output format of WMIC utility.
rem

if {%U_D80F55CE_C8D2_4FAE_832F_75830663E585%} == {} (

    echo Switching to UNICODE mode.
    echo Output file name: %OUTFILE%
    echo Running "%0" . . .

    set U_D80F55CE_C8D2_4FAE_832F_75830663E585=1
    cmd /u /c "%0" > %OUTFILE%
    echo.
    goto :eof
)

@echo off

rem
rem Basic runtime environment information
rem

rem This must be the first command in order to write the correct prefix to the UNICODE text file.
wmic OS get BuildNumber, CurrentTimeZone, Debug, OSArchitecture, Version /value

ver
echo DateTime=%date%-%time%
echo.
echo FormatVersion=%FILEFORMATVERSION%


rem
rem Essential data for quick diagnostic
rem

echo.
echo =======================================================================
echo.
echo     NOTE: CONTENT OF THIS FILE AND THIS SECTION IN PARTICULAR
echo           IS SUBJECT OT CHANGE. DO NOT MAKE ANY ASSUMPTIONS
echo           ABOUT THE LAYOUT OR CONTENT.
echo.
echo     This part contains essential data for quick diagnostic.
echo.
echo     DIFFERENCES IN EACH SECTION MAY INDICATE A POTENTIAL ISSUE.
echo.
echo =======================================================================
echo.

rem
rem PnP Class GUIDs for interesting devices:
rem SCSI Adapter, HDC, CD-ROM, Bluetooth
rem
set PNP_CLASSGUIDS=ClassGuid = '{4d36e97b-e325-11ce-bfc1-08002be10318}'
set PNP_CLASSGUIDS=ClassGuid = '{4d36e96a-e325-11ce-bfc1-08002be10318}' OR %PNP_CLASSGUIDS%
set PNP_CLASSGUIDS=ClassGuid = '{4d36e965-e325-11ce-bfc1-08002be10318}' OR %PNP_CLASSGUIDS%
set PNP_CLASSGUIDS=ClassGuid = '{e0cbf06c-cd8b-4647-bb8a-263b43f0f974}' OR %PNP_CLASSGUIDS%

rem
rem SMBIOS Record type 0 data:
rem
rem     ------------- -------------------
rem     SMBIOS        WMI
rem     ------------- -------------------
rem     Vendor        Manufacturer
rem
call :WmicPath Win32_BIOS get Manufacturer

rem
rem SMBIOS Record type 1 data:
rem
rem     ------------- -------------------
rem     SMBIIOS        WMI
rem     ------------- -------------------
rem     Serial Number  Identifying Number
rem     Product Name   Name
rem     UUID           UUID
rem     Manufacturer   Vendor
rem
call :WmicPath Win32_ComputerSystemProduct get IdentifyingNumber, Name, UUID, Vendor

rem
rem CPU
rem
call :WmicPath Win32_Processor get CpuStatus, Description, ProcessorId

rem
rem Memory modules
rem
call :WmicPath Win32_PhysicalMemory get Capacity, DeviceLocator, Manufacturer, PartNumber, SerialNumber

rem
rem Disks, excluding USB disks
rem
call :WmicPath Win32_DiskDrive where "InterfaceType<>'USB'" get FirmwareRevision, InterfaceType, Model, SerialNumber

rem
rem Network Adpaters with MAC addresses
rem     Exclude RAS Async Adapter
rem     Include Bluetooth adapters
rem
call :WmicPath Win32_NetworkAdapter where "(MACAddress is not NULL AND Description <> 'RAS Async Adapter') OR Description LIKE '%%%%Bluetooth%%%%'" get AdapterType, Description, MACAddress


rem
rem Good for diagnostic, but is likely to contain noise
rem

echo.
echo =======================================================================
echo.
echo     This part contains information that may be useful for further
echo     investigation.
echo.
echo     DIFFERENCES DO NOT NECESSERILY INDICATE ANY POTENTIAL ISSUE.
echo.
echo =======================================================================
echo.

rem
rem IDE Controllers
rem
call :WmicPath Win32_IDEController  get Name, Manufacturer

rem
rem SCSI Controllers
rem
call :WmicPath Win32_SCSIController where "DriverName <> 'spaceport'" get DriverName, Name, Manufacturer

rem
rem PnP Objects for select PnP Device Classes
rem
call :WmicPath Win32_PnPEntity where "%PNP_CLASSGUIDS% AND Service <> 'spaceport'" get ClassGuid, Description, Service

rem
rem More disk information, but may not work in WinPE
rem
call :WmicPath2 "\\Root\Microsoft\Windows\Storage" path MSFT_PhysicalDisk where "NOT UniqueId LIKE 'USBSTOR%%%%'" get FirmwareVersion, Manufacturer, Model, SerialNumber, Size

rem
rem PnP Signed Drivers for select PnP Device Classes
rem
call :WmicPath Win32_PnPSignedDriver where "(%PNP_CLASSGUIDS%) AND NOT (HardWareID LIKE '%%%%Spaceport')" get ClassGuid, Description, DeviceClass, DeviceName, DriverDate, DriverProviderName, DriverVersion, InfName, DeviceClass,  InfName, FriendlyName, HardwareId, Manufacturer, Signer

rem
rem This section outputs detailed information about the system, but a lot of noise.
rem

echo.
echo =======================================================================
echo.
echo     This part contains much more unfiltered, detailed information
echo     that may be useful for further investigation.
echo.
echo     DIFFERENCES DO NOT INDICATE ANY POTENTIAL ISSUE.
echo.
echo =======================================================================
echo.

call :WmicPathGet Win32_OperatingSystem

call :WmicPathGet Win32_ComputerSystemProduct
call :WmicPathGet Win32_BIOS
call :WmicPathGet Win32_Baseboard
call :WmicPathGet Win32_SystemEnclosure
call :WmicPathGet Win32_ComputerSystem

call :WmicPathGet Win32_Processor

call :WmicPathGet Win32_PhysicalMemoryArray
call :WmicPathGet Win32_PhysicalMemory
call :WmicPathGet Win32_PhysicalMemoryLocation

call :WmicPathGet Win32_CDROMDrive
call :WmicPathGet Win32_DiskDrive
call :WmicPathGet2 "\\Root\Microsoft\Windows\Storage" MSFT_Disk
call :WmicPathGet2 "\\Root\Microsoft\Windows\Storage" MSFT_PhysicalDisk

call :WmicPathGet Win32_NetworkAdapter
rem  :WmicPathGet Win32_NetworkAdapterConfiguration
rem  :WmicPathGet Win32_NetworkAdapterSetting

call :WmicPathGet Win32_IDEController
call :WmicPathGet Win32_IDEControllerDevice

call :WmicPathGet Win32_SCSIController
call :WmicPathGet Win32_SCSIControllerDevice

call :WmicPathGet Win32_USBHub
call :WmicPathGet Win32_USBController
call :WmicPathGet Win32_USBControllerDevice

call :WmicPathGet Win32_SoundDevice

call :WmicPathGet Win32_VideoController

call :WmicPathGet Win32_1394Controller
call :WmicPathGet Win32_1394ControllerDevice

call :WmicPathGet Win32_PCMCIAController

call :WmicPathGet Win32_MotherboardDevice
call :WmicPathGet Win32_DesktopMonitor
call :WmicPathGet Win32_FloppyController
call :WmicPathGet Win32_Keyboard
call :WmicPathGet Win32_SerialPort
call :WmicPathGet Win32_PointingDevice

call :WmicPathGet Win32_PnPEntity
call :WmicPathGet Win32_PnPSignedDriver

call :RegQuery "HKLM\System\CurrentControlSet\Enum\USB"  /s /v DeviceDesc
call :RegQuery "HKLM\System\CurrentControlSet\Enum\USB"  /s /v ContainerId
call :RegQuery "HKLM\System\CurrentControlSet\Enum\USB"  /s /v Mfg
call :RegQuery "HKLM\System\CurrentControlSet\Enum\USB"  /s /v Service

call :RegQuery "HKLM\System\CurrentControlSet\Enum\IDE"  /s /v ContainerId
call :RegQuery "HKLM\System\CurrentControlSet\Enum\SCSI" /s /v ContainerId

call :WmicPathGet2 "\\Root\wmi" MSSmBios_RawSMBiosTables

goto :EOF


:WmicPath

echo.
echo [%1]
wmic PATH %*

goto :EOF


:WmicPath2

echo.
echo [%3]
wmic /namespace:%*


goto :EOF


:WmicPathGet


echo ===========================================================
echo wmic PATH %1 get /value
echo -----------------------------------------------------------
wmic PATH %1 get /value

goto :EOF


:WmicPathGet2

echo ===========================================================
echo wmic /namespace:%1 PATH %2 get /value
echo -----------------------------------------------------------
wmic /namespace:%1 PATH %2 get /value

goto :EOF

:RegQuery

echo ===========================================================
echo reg query %*
echo -----------------------------------------------------------

SETLOCAL
set TEMPFILE=%TEMP%\machineinfo%RANDOM%.tmp
reg query %* > %TEMPFILE%
type %TEMPFILE%
del %TEMPFILE%
ENDLOCAL
echo.

goto :EOF

