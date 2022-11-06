@echo off
IF %NETDATA_WSL_VERSION%=="1" wsl -t netdata
ELSE wsl -d netdata killall netdata