# msi-installer
Netdata installer for Windows using WSL2

MSI file is self-contained, run it to unattendedly setup the Netdata agent, if WSL not installed will install it and reboot, after restart run MSI again manually.

Installer will register the WSL distro, modify the configuration files for windows_exporter, start the agent and add a startup item for it.

Optionally, agent can be added to cloud adding a TOKEN argument to the MSI launch command:

msiexec.exe /i netdatawsl.msi TOKEN=*token*

WXS file will build the MSI file through the WiX toolset.

docker-to-tar.sh will generate the netdata.tar file containing the WSL distro using the public Netdata/netdata Docker image and used by WiX.

The windows_exporter MSI file is not included and must be installed before as its installation can't be embedded into another MSI file per Windows Installer limitations.

If agent doesn't show WMI metrics a restart is necessary.

Uninstallation from Control Panel removes the WSL distro including netdata configuration files.