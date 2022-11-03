# Netdata MSI Installer

Netdata installer for Windows using WSL

## Instructions

On your Windows machine:
- Install the latest [Prometheus exporter for Windows](https://github.com/prometheus-community/windows_exporter/releases).
- Download the [netdata.msi](https://github.com/netdata/msi-installer/releases)
- Run netdata.msi directly, or with the options provided by Netdata Cloud. It will install WSL2 or WSL1 and run Netdata on your machine. 
  **If WSL is not installed, the installer will add it and reboot the server**. After restart, run the MSI again manually.

## Installation Details

The MSI file is self-contained. Run it to unattendedly setup the Netdata agent. 

The installer will register the WSL distribution called "Netdata", start the agent and add a startup item for the current user.

The agent can be added to Netdata Cloud by copy/pasting the add node command from your space. e.g.:

msiexec.exe /i netdata.msi TOKEN=*token* ROOMS=*room list* URL=https://app.netdata.cloud 

To disable telemetry add the binary argument TELEMETRY=0:

msiexec.exe /i "netdata.msi" TELEMETRY=0

## Netdata configuration

For a single instance, you can bring up the linux prompt via `wsl -d Netdata`, then `cd /etc/netdata` and use `./edit-config`. 
For an infrastructure-wide deployment use your preferred deployment tool and do the following:

1. Put all your custom netdata configs under a directory in the target machine (e.g. under c:Users/Public/custom-netdata-config-file-directory)

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
3. Restart netdata
```
restart-netdata
```

## Uninstall

Uninstallation from  the Control Panel (Add or remove programs) removes the WSL distro, including the netdata configuration files. The name of the program is "NetdataWSL".

# build
WXS file will build the MSI file through the WiX toolset.

docker_image_to_wsl_tar will generate the netdata.tar file containing the WSL distro using the public Netdata/netdata Docker image and used by WiX.


