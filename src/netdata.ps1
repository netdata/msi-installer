# Check if already installed
if(test-path installed) {	
	# remove netdata installation task
	schtasks.exe /delete /tn netdata /f
	exit
}

Write-Output "ENABLING WSL WINDOWS FEATURE"
Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -NoRestart -OutVariable results
if ($LASTEXITCODE) {
	Write-Output "WSL WINDOWS FEATURE COULD NOT BE INSTALLED"
	exit 1
}
if ($results.RestartNeeded -eq $true) {
	$restart = $true
}

Write-Output "ENABLING VIRTUAL MACHINE PLATFORM WINDOWS FEATURE"
Enable-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -All -Online -NoRestart -OutVariable results
if ($LASTEXITCODE) {
	Write-Output "VIRTUAL MACHINE PLATFORM WINDOWS FEATURE COULD NOT BE INSTALLED"
}
if ($results.RestartNeeded -eq $true) {
	$restart = $true
}

Write-Output "REMOVING FIREWALL RULE FOR WSL1"
Remove-NetFirewallRule -DisplayName netdata

Write-Output "ADDING FIREWALL RULE FOR WSL1"
New-NetFirewallRule -Program C:\NetdataWSL\rootfs\usr\sbin\netdata -Action Allow -Profile Domain,Private,Public -DisplayName netdata -Description netdata -Direction Inbound

Write-Output "CREATING NETDATA INSTALLATION TASK"
cmd.exe /c schtasks /create /xml netdata-task.xml /tn netdata

# check if installation already restarted
if (-Not (test-path restart)) {
	# save arguments
	Write-Output "SAVING ARGUMENTS"
	$args[0] > token.txt
	$args[1] > rooms.txt
	$args[2] > url.txt
	$args[3] > telemetry.txt
	# set restart flag
	New-Item restart | Out-Null
	# Restart before continuing installation
	Write-Output "RESTARTING"
	Restart-Computer -Force
	exit
} else { rm restart}

# wsl2 kernel update can't be installed until reboot after wsl installation
Write-Output "INSTALLING WSL2 KERNEL UPDATE"
cmd.exe /c update_wsl2_kernel.cmd

Write-Output "INSTALLING WINDOWS_EXPORTER.MSI"
cmd.exe /c install_windows_exporter.cmd

Write-Output "UNREGISTERING NETDATA WSL DISTRO"
cmd.exe /c wsl --unregister netdata

Write-Output "REGISTERING NETDATA WSL DISTRO"
cmd.exe /c wsl --import Netdata C:\NetdataWSL Netdata.tar

Write-Output "ADDING SCRIPTS TO PATH"
$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
$newpath = $oldpath + ";c:\program files (x86)\netdata"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newpath

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
