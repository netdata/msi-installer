# Netdata MSI Installer

Netdata installer for Windows using WSL

## Instructions

On your Windows machine:

- Download the [netdata.msi](https://github.com/netdata/msi-installer/releases)
- Run netdata.msi directly, or with the options provided by Netdata Cloud. 

The MSI installer includes and installs automatically the following dependencies:
- [Prometheus exporter for Windows](https://github.com/prometheus-community/windows_exporter/releases).
- [WSL2 Linux kernel update package for x64 machines](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)

If WSL2 can't be installed, WSL1 will be installed instead. 

**The installer will reboot the server** in order to install all the dependencies. After restart, the installation will finish automatically.
  
## Installation Details

The MSI file is self-contained. Run it to unattendedly setup the Netdata agent. 

The installer will register the WSL distribution called "Netdata", start the agent and add a startup item for the current user.

The agent can be added to Netdata Cloud by copy/pasting the add node command from your space. e.g.:

```msiexec.exe /i netdata.msi TOKEN=*token* ROOMS=*room list* URL=https://app.netdata.cloud```

To disable telemetry add the binary argument TELEMETRY=0:

```msiexec.exe /i "netdata.msi" TELEMETRY=0```

The installation log can be found at `C:\NETDATA.LOG`

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

## Build

The WXS file will build the MSI file through the WiX toolset.

`docker_image_to_wsl_tar` will generate the netdata.tar file containing the WSL distro using the public Netdata/netdata Docker image and used by WiX.


