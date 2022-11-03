# Check if already installed
if(test-path installed) {	
	# remove netdata installation task
	schtasks.exe /delete /tn netdata /f
	exit
}

Write-Output "Enabling WSL Windows feature"
Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -NoRestart -OutVariable results
if ($LASTEXITCODE) {
	Write-Output "WSL Windows feature could not be installed"
	exit 1
}
if ($results.RestartNeeded -eq $true) {
	$restart = $true
}

Write-Output "Enabling Virtual Machine Platform Windows feature"
Enable-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -All -Online -NoRestart -OutVariable results
if ($LASTEXITCODE) {
	Write-Output "Virtual Machine Platform Windows feature could not be installed"
}
if ($results.RestartNeeded -eq $true) {
	$restart = $true
}

Write-Output "Removing Firewall rule for WSL1"
Remove-NetFirewallRule -DisplayName netdata

Write-Output "Adding Firewall rule for WSL1"
New-NetFirewallRule -Program C:\NetdataWSL\rootfs\usr\sbin\netdata -Action Allow -Profile Domain,Private,Public -DisplayName netdata -Description netdata -Direction Inbound

Write-Output "Creating netdata installation task"
cmd.exe /c schtasks /create /xml netdata-task.xml /tn netdata

# check if installation already restarted
if (-Not (test-path restart)) {
	# save arguments
	Write-Output "Saving arguments"
	$args[0] > token.txt
	$args[1] > rooms.txt
	$args[2] > url.txt
	$args[3] > telemetry.txt
	# set restart flag
	New-Item restart | Out-Null
	# Restart before continuing installation
	Write-Output Restarting
	Restart-Computer -Force
	exit
} else { rm restart}

# wsl2 kernel update can't be installed until reboot after wsl installation
Write-Output "Installing WSL2 kernel update"
cmd.exe /c update_wsl2_kernel.cmd

Write-Output "Installing windows_exporter.msi"
cmd.exe /c install_windows_exporter.cmd

Write-Output "Unregistering Netdata WSL distro"
cmd.exe /c wsl --unregister netdata

Write-Output "Registering Netdata WSL distro"
cmd.exe /c wsl --import Netdata C:\NetdataWSL Netdata.tar

Write-Output "Adding scripts to path"
$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
$newpath = $oldpath + ";c:\program files (x86)\netdata"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newpath

# Handle claim and telemetry arguments
# Defaults are defined in netdata.wxs:
# TOKEN=0 (no token) ROOMS=0 (no room) URL=https://app.netdata.cloud TELEMETRY=1 (telemetry enabled)
$token = get-content token.txt

$token

$rooms = get-content rooms.txt
$url = get-content url.txt
$telemetry = get-content telemetry.txt

# Claim if arguments not default
if ($token -ne "0") {
	Write-Output Claiming
	if ($rooms -eq "0") {
		cmd.exe /c "wsl -d netdata netdata-claim.sh -token=$token -url=$url"
	} else {
		cmd.exe /c "wsl -d netdata netdata-claim.sh -token=$token -rooms=$rooms -url=$url"
	}
}
if ($telemetry -eq "0") {
	cmd.exe /c wsl -d netdata touch /etc/netdata/.opt-out-from-anonymous-statistics
}

Write-Output "Starting agent"
cmd.exe /c wsl -d netdata netdata

Write-Output "Adding Netdata to startup"
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name Netdata -Value 'wsl.exe -d Netdata netdata'

# write installation flag file
New-Item installed | Out-Null