@echo off
SETLOCAL

REM MSI parameters
REM Defaults are TOKEN=0 (no token) ROOMS=0 (no room) URL=https://app.netdata.cloud TELEMETRY=1 (telemetry enabled)

set token=%1
set rooms=%2
set url=%3
set telemetry=%4

REM Claim if there's a token argument else jump to telemetry
if "%token%"=="0" goto TELEMETRY
if "%rooms%"=="0" (
  wsl -d netdata netdata-claim.sh -token=%token% -url=%url%
) else (
  wsl -d netdata netdata-claim.sh -token=%token% -rooms=%rooms% -url=%url%
)

:TELEMETRY
if "%telemetry%"=="0" wsl -d netdata touch /etc/netdata/.opt-out-from-anonymous-statistics
ENDLOCAL