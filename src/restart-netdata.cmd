@echo off
IF "%NETDATA_WSL_VERSION%"=="1" (
	wsl -t netdata & wsl -d netdata netdata
) ELSE (
	wsl -d netdata bash -c "killall netdata ; netdata"
)