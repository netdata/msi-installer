# Netdata MSI Installer

Netdata installer for Windows using WSL

## Prerequisites

Install the Prometheus WMI windows_exporter, by following the instructions [here](https://learn.netdata.cloud/docs/agent/collectors/go.d.plugin/modules/wmi#requirements)

## Instructions

Download the msi here. TODO ADD PROPER LINK WHEN MSI IS RENAMED 

The MSI file is self-contained. Run it to unattendedly setup the Netdata agent. 

If WSL is not installed, the installer will add it and reboot the server. After restart, run the MSI again manually.

Installer will register the WSL distro, start the agent and add a startup item for the current user.

Agent can be added to Netdata Cloud by copy/pasting the add node command from your space. e.g.:

msiexec.exe /i netdata.msi TOKEN=*token* ROOMS=*room list* URL=https://app.netdata.cloud 

To disable telemetry add the binary argument TELEMETRY=0:

msiexec.exe /i "netdata.msi" TELEMETRY=0

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
wsl -d netdata netdatacli shutdown-agent & wsl -d netdata netdata
```

## Start/Stop Netdata
1. Start netdata
```
wsl -d netdata netdata
```
2. Stop netdata
```
wsl -d netdata netdatacli shutdown-agent
```