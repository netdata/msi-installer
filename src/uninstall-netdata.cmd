@echo off
echo Unregister Netdata WSL distro
cmd.exe /c wsl --unregister netdata
echo Remove logon task
schtasks.exe /delete /tn netdata /f
echo Remove "installed" flag file
del installed
echo Remove token
del /q *.txt
rmdir c:\netdatawsl