@echo off
SETLOCAL

REM MSI parameters
REM Defaults are TOKEN=0 (no token) ROOMS=0 (no room) URL=https://api.netdata.cloud TELEMETRY=1 (telemetry enabled)

set token=%1
set rooms=%2
set url=%3
set telemetry=%4

REM Removing old distro if exists
wsl --unregister netdata

echo Registering...
wsl --import Netdata C:\NetdataWSL Netdata.tar

REM netdata.conf setup
wsl -d Netdata sh netdata.conf.sh

REM wmi.conf setup
REM wsl -d Netdata sh wmi.conf.sh

REM Starting Netdata program
wsl -d Netdata netdata

REM Claim if there's a token argument
if "%token%"=="0" goto TEL
if "%rooms%"=="0" (
  wsl -d netdata netdata-claim.sh -token=%token% -url=%url%
) else (
  wsl -d netdata netdata-claim.sh -token=%token% -rooms=%rooms% -url=%url%
)
:TEL
if "%telemetry%"=="0" wsl -d netdata touch /etc/netdata/.opt-out-from-anonymous-statistics
ENDLOCAL