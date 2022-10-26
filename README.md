# msi-installer
Netdata installer for Windows using WSL

MSI file is self-contained, run it to unattendedly setup the Netdata agent, if WSL not installed will install it and reboot, after restart run MSI again manually.

Installer will register the WSL distro, start the agent and add a startup item for the current user.

Agent can be added to cloud adding the optional TOKEN, ROOMS and URL arguments to the MSI launch command:

msiexec.exe /i "NetdataWSL Windows Installer.msi" TOKEN=*token* ROOMS=*room" URL=https://api.netdata.cloud 

To disable telemetry add the binary argument TELEMETRY=0:

msiexec.exe /i "NetdataWSL Windows Installer.msi" TELEMETRY=0

# build
WXS file will build the MSI file through the WiX toolset.

docker_image_to_wsl_tar will generate the netdata.tar file containing the WSL distro using the public Netdata/netdata Docker image and used by WiX.

The windows_exporter MSI file is not included and must be installed before as its installation can't be embedded into another MSI file per Windows Installer limitations.

If agent doesn't show WMI metrics a restart is necessary.

Uninstallation from Control Panel removes the WSL distro including netdata configuration files.

## Configuring netdata
1. Put all the netdata configs under a directory in the host machine (e.g. under c:Users/Public/custom-netdata-config-file-directory)
2. Copy the config files
```
wsl -d Netdata cp -a /mnt/c/Users/Public/custom-netdata-config-file-directory/ /etc/netdata
```
3. Restart netdata
```
wsl -t netdata & wsl -d netdata netdata
```