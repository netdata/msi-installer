# :warning: _This installation method is no longer supported_ :warning:

It has always had some serious issues that mean it’s not production quality, not to mention the issues inherent in trying to use WSL for production workloads. For Netdata v2.0 and newer, the running natively on Windows is the only officially supported method for monitoring Windows hosts. For versions prior to v2.0, the officially supported method for monitoring Windows hosts is to install the agent on a properly supported platform (which notably does not include WSL) and monitor the Windows host remotely via the Windows Exporter collector as outlined at https://learn.netdata.cloud/docs/collecting-metrics/windows-systems/windows.

_**ALL**_ support requests regarding this installer will be be closed with reference to the officially supported monitoring methods for Windows hosts.

# Netdata MSI Installer

Netdata installer for Windows using WSL. Use this installer to quickly explore how Netdata monitors Windows hosts. 

For production use, you will need to [install Netdata on a Linux host]([https://learn.netdata.cloud/docs/agent/collectors/go.d.plugin/modules/wmi#remote-data-collection](https://learn.netdata.cloud/docs/agent/collectors/go.d.plugin/modules/wmi#requirements)). 

## Instructions

On your Windows machine:

- Download the [latest netdata.msi](https://github.com/netdata/msi-installer/releases)
- Open an **admin** CMD terminal (not Powershell) and run `msiexec -i [PATH TO MSI]\netdata.msi [OPTIONS]` 

> :warning: **Running directly the MSI will cause installation to fail**. Only install via `msiexec`.

> :warning: **You will need to reboot your server** in order to finish the installation and **a user needs to log in, after the reboot**, due to https://github.com/microsoft/WSL/issues/2979.


## Installation Details

The MSI installer includes and installs automatically the following dependencies:
- [Prometheus exporter for Windows](https://github.com/prometheus-community/windows_exporter/releases).
- [WSL2 Linux kernel update package for x64 machines](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi).

If WSL2 can't be used, WSL1 will be used instead. 

The MSI file is self-contained. Run it to setup the Netdata agent. 

The installer will register the WSL distribution called "Netdata", start the agent and add a startup item for the current user.

The agent can be added to Netdata Cloud by running the following as an administrator:

```msiexec.exe /i C:\PATH-TO-MSI\netdata.msi TOKEN=[Claim token] ROOMS=[Room IDs] URL=https://api.netdata.cloud```

You take the values of [token] and [rooms] from Netdata Cloud. e.g.

<img width="665" alt="image" src="https://github.com/netdata/msi-installer/assets/43294513/be6fff1d-49be-4ad3-a6d7-78396fcdce9b">

To disable telemetry add the binary argument TELEMETRY=0:

```msiexec.exe /i C:\PATH-TO-MSI\netdata.msi TELEMETRY=0```

The installation log can be found at `C:\NETDATA.LOG`

To enable an automatic restart, use binary argument AUTORESTART=1:

```msiexec.exe /i C:\PATH-TO-MSI\netdata.msi AUTORESTART=1```

To specify the WSL version to be used use integer argument WSL=1:

```msiexec.exe /i C:\PATH-TO-MSI\netdata.msi WSL=1```

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


