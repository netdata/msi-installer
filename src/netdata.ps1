# Check if already installed
if(test-path installed) {	
	Write-Output REMOVING INSTALLATION LOGON TASK
	schtasks.exe /delete /tn netdata /f
	exit
}

# checking if installation already run
if (test-path restart) {
	Write-Output "CONTINUING INSTALLATION"
}

if (-Not (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq "Enabled") {
	Write-Output "WSL IS NOT INSTALLED, ENABLING IT"
	Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -NoRestart
	if ($LASTEXITCODE) {
		Write-Output "WSL COULD NOT BE INSTALLED"
		exit 1
	}	
} else {
	Write-Output "WSL ALREADY INSTALLED, SKIPPING INSTALLING IT"
}

if (-Not (Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State -eq "Enabled") {
	Write-Output "VIRTUAL MACHINE PLATFORM FEATURE IS NOT INSTALLED, ENABLING IT"
	Enable-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -Online -NoRestart
	if ($LASTEXITCODE) {
		Write-Output "VIRTUAL MACHINE PLATFORM FEATURE COULD NOT BE INSTALLED"
	}	
} else {
	Write-Output "VIRTUAL MACHINE PLATFORM FEATURE ALREADY INSTALLED, SKIPPING INSTALLING IT"
}

if (-Not (Get-NetFirewallRule -DisplayName netdata -ErrorAction SilentlyContinue)) {
	Write-Output "ADDING FIREWALL RULE FOR WSL1"
	New-NetFirewallRule -Program C:\NetdataWSL\rootfs\usr\sbin\netdata -Action Allow -Profile Domain,Private,Public -DisplayName netdata -Description netdata -Direction Inbound
} else {
	Write-Output "FIREWALL RULE FOR WSL1 EXISTS"
}

Write-Output "CHECKING FOR INSTALLATION LOGON TASK"
cmd.exe /c schtasks /query /tn netdata
if ($LASTEXITCODE) {
	Write-Output "CREATING NETDATA INSTALLATION LOGON TASK"
	cmd.exe /c schtasks /create /xml netdata-task.xml /tn netdata
}

# check if installation already restarted
if (-Not (test-path restart)) {
	Write-Output "NO RESTARTED FLAG DETECTED"
	# save arguments
	Write-Output "SAVING ARGUMENTS"
	$args[0] > token.txt
	$args[1] > rooms.txt
	$args[2] > url.txt
	$args[3] > telemetry.txt
	# set restart flag
	Write-Output "SAVING RESTARTED FLAG"
	New-Item restart | Out-Null
	# Restart before continuing installation
	Write-Output "REQUESTING RESTARTING"
	Restart-Computer -Force
	Write-Output "RESTART REQUESTED, EXITING SCRIPT"
	exit
} else {
	Write-Output "RESTARTED FLAG DETECTED, REMOVING IT AND CONTINUINING SCRIPT"
	Remove-Item restart
}

# wsl2 kernel update can't be installed until reboot after wsl installation
Write-Output "INSTALLING WSL2 KERNEL UPDATE"
cmd.exe /c update_wsl2_kernel.cmd

Write-Output "INSTALLING WINDOWS_EXPORTER.MSI"
cmd.exe /c install_windows_exporter.cmd

if (-Not (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq "Enabled") {
	Write-Output "WSL FEATURE IS NOT INSTALLED, ABORTING"
	exit
}

Write-Output "UNREGISTERING NETDATA WSL DISTRO"
cmd.exe /c wsl --unregister netdata

Write-Output "REGISTERING NETDATA DISTRO WITH WSL2"
$version = 2
cmd.exe /c wsl --import Netdata C:\NetdataWSL Netdata.tar --version $version
if ($LASTEXITCODE) {
	Write-Output "WSL DISTRO COULDN'T BE IMPORTED USING WSL2, TRYING WITH WSL1"
	$version = 1
	cmd.exe /c wsl --import Netdata C:\NetdataWSL Netdata.tar --version $version
}
if ($LASTEXITCODE) {
	Write-Output "WSL DISTRO COULD NOT BE IMPORTED WITH EXPLICIT VERSION 1, TRYING DEFAULT OPTION"
	cmd.exe /c wsl --import Netdata C:\NetdataWSL Netdata.tar
}
if ($LASTEXITCODE) {
	Write-Output "WSL DISTRO COULD NOT BE IMPORTED, ABORTING"	
	exit
} else {
	Write-Output "WSL DISTRO REGISTERED"
	#saving wsl version used in version file
	$version | Set-Content -Encoding ascii -NoNewLine .\version
}

# saving wsl version used in machine env var netdata_wsl_version
cmd.exe /c setx /m NETDATA_WSL_VERSION $version

Write-Output "ADDING SCRIPTS TO PATH"
cmd.exe /c 'setx PATH "%PATH%;c:\program files (x86)\netdata"'

# Handle claim and telemetry arguments
# Defaults are defined in netdata.wxs:
# TOKEN=0 (no token) ROOMS=0 (no room) URL=https://app.netdata.cloud TELEMETRY=1 (telemetry enabled)
$token = get-content token.txt
$rooms = get-content rooms.txt
$url = get-content url.txt
$telemetry = get-content telemetry.txt

# Claim if arguments not default
if ($token -ne "0") {
	Write-Output "CLAIMING"
	if ($rooms -eq "0") {
		cmd.exe /c "wsl -d netdata netdata-claim.sh -token=$token -url=$url"
	} else {
		cmd.exe /c "wsl -d netdata netdata-claim.sh -token=$token -rooms=$rooms -url=$url"
	}
}
if ($telemetry -eq "0") {
	cmd.exe /c wsl -d netdata touch /etc/netdata/.opt-out-from-anonymous-statistics
}

Write-Output "STARTING AGENT"
cmd.exe /c wsl -d netdata netdata

Write-Output "ADDING NETDATA TO STARTUP"
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name Netdata -Value 'wsl.exe -d Netdata netdata'

# write installation flag file
New-Item installed | Out-Null

Write-Output "INSTALLATION FINISHED"
