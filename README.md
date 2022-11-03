# Netdata MSI Installer

Netdata installer for Windows using WSL

## Instructions

On your Windows machine:
- Download the [netdata.msi](https://github.com/netdata/msi-installer/releases)
- Run netdata.msi directly, or with the options provided by Netdata Cloud. It will install WSL2 or WSL1 and run Netdata on your machine.

## Details

The MSI file is self-contained. Run it to unattendedly setup the Netdata agent. 

If WSL is not installed, the installer will add it. The installer will restart and after logon installation will resume automatically.

Installer will register the WSL distro, start the agent and add a startup item for the current user.

Agent can be added to Netdata Cloud by copy/pasting the add node command from your space. e.g.:

msiexec.exe /i netdata.msi TOKEN=*token* ROOMS=*room list* URL=https://app.netdata.cloud 

To disable telemetry add the binary argument TELEMETRY=0:

msiexec.exe /i "netdata.msi" TELEMETRY=0

# build
WXS file will build the MSI file through the WiX toolset.

docker_image_to_wsl_tar will generate the netdata.tar file containing the WSL distro using the public Netdata/netdata Docker image and used by WiX.

The MSI installer includes and installs automatically the following dependencies:
- [Prometheus exporter for Windows](https://github.com/prometheus-community/windows_exporter/releases).
- [WSL2 Linux kernel update package for x64 machines](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)

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
restart-netdata
```

## Start/Stop Netdata

1. Start netdata
```
start-netdata
```
2. Stop netdata
```
stop-netdata
```
