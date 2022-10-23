@echo off
echo Registering...
wsl --import Netdata C:\NetdataWSL Netdata.tar
wsl -d Netdata sh netdata.conf.sh
wsl -d Netdata sh wmi.conf.sh
wsl -d Netdata netdata
if exist token.txt (
  set /p token=<token.txt
)
if not "%token%"=="" (
  wsl -d netdata netdata-claim.sh -token=%token%
)