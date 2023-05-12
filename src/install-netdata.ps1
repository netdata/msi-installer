# assigning arguments from MSI or disk
if (-Not (test-path restart)) {
	$token = $args[0]
	$rooms = $args[1]
	$url = $args[2]
	$telemetry = $args[3]
	$autorestart = $args[4]
	$version = $args[5]
	$winexpport = $args[6]
} else {
	$token = Get-Content token.txt
	$rooms = Get-Content rooms.txt
	$url = Get-Content url.txt
	$telemetry = Get-Content telemetry.txt
	$version = Get-Content version.txt
	$winexpport = Get-Content winexpport.txt
}

# start 1st phase if not restart
if (-Not (test-path restart)) {	
	# don't reinstall wsl and reboot when upgrading
	if (-Not (test-path installed)) {
		# save arguments in disk to use after restart
		$token | Set-Content -Encoding ascii -NoNewLine token.txt
		$rooms | Set-Content -Encoding ascii -NoNewLine rooms.txt
		$url | Set-Content -Encoding ascii -NoNewLine url.txt
		$telemetry | Set-Content -Encoding ascii -NoNewLine telemetry.txt
		$version | Set-Content -Encoding ascii -NoNewLine version.txt
		$winexpport | Set-Content -Encoding ascii -NoNewLine winexpport.txt
		Write-Output "STARTING INSTALLATION"
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
		# set restart flag
		Write-Output "SAVING RESTART FLAG"
		New-Item restart | Out-Null
		
		Write-Output "CREATING NETDATA INSTALLATION LOGON TASK"
		cmd.exe /c schtasks /create /xml netdata-task.xml /tn netdata			

		# handle autorestart parameter
		if ($autorestart) {
			# restarting before continuing installation
			Write-Output "REQUESTING RESTART"
			# Restart-Computer -Force
			Restart-Computer
			Write-Output "RESTART REQUESTED, EXITING SCRIPT"
		} else {
			Write-Output "NO AUTORESTART DETECTED, INSTALLATION WILL CONTINUE AFTER RESTART"
			Add-Type -AssemblyName PresentationFramework
			[System.Windows.MessageBox]::Show('Installation will continue after restart');
		}
		exit
	} else {
		Write-Output "UPGRADING"
	}		
} else {
	Write-Output "CONTINUING INSTALLATION"	
	Remove-Item restart
}

# checking if wsl enabled before continuing
if (-Not (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq "Enabled") {
	Write-Output "WSL FEATURE IS NOT INSTALLED, ABORTING"
	exit
}

# install dependencies when not upgrading
if (-Not (test-path installed)) {
	# wsl2 kernel update can't be installed until reboot after wsl installation
	Write-Output "INSTALLING WSL2 KERNEL UPDATE"
	cmd.exe /c update_wsl2_kernel.cmd

	Write-Output "INSTALLING WINDOWS_EXPORTER"
	
	cmd.exe /c "install_windows_exporter.cmd $winexpport"
}

if (test-path installed) {
	Write-Output "BACKING UP CONFIGURATION"	
	cmd.exe /c wsl -d netdata tar zcvf /mnt/c/netdata/netdatacfg.tar /etc/netdata /var/lib/netdata /var/cache/netdata 2>&1 | %{ "$_" }
}

Write-Output "UNREGISTERING NETDATA WSL DISTRO"
cmd.exe /c wsl --unregister netdata

Write-Output "TRYING TO IMPORT NETDATA DISTRO WITH WSL$version"
Write-Output "PLEASE WAIT FOR A FEW MINUTES"
$timeout = 2 # minutes
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "wsl.exe"
$pinfo.RedirectStandardError = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false
$pinfo.Arguments = "--import Netdata C:\Netdata Netdata.tar --version $version"
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start() | Out-Null
if (-Not($p.WaitForExit($timeout * 60 * 1000))) {
	$p.kill()    
}
$stdout = $p.StandardOutput.ReadToEnd()
$stderr = $p.StandardError.ReadToEnd()
Write-Host $stdout
Write-Host $stderr
if ($p.Exitcode -ne 0) {
	Write-Output "WSL DISTRO COULDN'T BE IMPORTED USING WSL2, TRYING WITH WSL1"
	$version = 1
	cmd.exe /c wsl --import Netdata C:\Netdata Netdata.tar --version $version
	if ($LASTEXITCODE) {
		Write-Output "WSL DISTRO COULD NOT BE IMPORTED WITH VERSION SWITCH, TRYING DEFAULT OPTION"
		cmd.exe /c wsl --import Netdata C:\Netdata Netdata.tar
	}
	if ($LASTEXITCODE) {
		Write-Output "WSL DISTRO COULD NOT BE IMPORTED, ABORTING"	
		exit
	}
}
Write-Output "WSL DISTRO REGISTERED"
#saving wsl version used in version file
$version | Set-Content -Encoding ascii -NoNewLine version.txt

Write-Output "ADJUSTING DISTRO"
cmd.exe /c wsl -d netdata sh adjust_distro.sh

Write-Output "SAVING WSL VERSION USED IN MACHINE ENV VAR NETDATA_WSL_VERSION"
cmd.exe /c "setx /m NETDATA_WSL_VERSION $version > nul"

Write-Output "REMOVING FIREWALL RULE FOR WSL1 IF EXISTS"
if (Get-NetFirewallRule -DisplayName netdata -ErrorAction SilentlyContinue) {
	Remove-NetFirewallRule -DisplayName netdata
}
if ($version -eq "1") {	
	Write-Output "ADDING FIREWALL RULE FOR WSL1"
	New-NetFirewallRule -Program C:\Netdata\rootfs\usr\sbin\netdata -Action Allow -Profile Domain,Private,Public -DisplayName netdata -Description netdata -Direction Inbound	
}

if (test-path installed) {
	Write-Output "RESTORING CONFIGURATION"
	wsl -d netdata tar zxvf /mnt/c/netdata/netdatacfg.tar -C /
	wsl -d netdata rm -f /mnt/c/netdata/netdatacfg.tar
}

# Handle claim and telemetry arguments
# Defaults are defined in netdata.wxs:
# TOKEN=0 (no token) ROOMS=0 (no room) URL=https://app.netdata.cloud TELEMETRY=1 (telemetry enabled)

# Claim if arguments not default
if ($token -ne "0") {
	Write-Output "CLAIMING"
	if ($rooms -eq "0") {
		cmd.exe /c wsl -d /usr/sbin/netdata-claim.sh -token=$token -url=$url -daemon-not-running 2>&1 | %{ "$_" }
	} else {
		cmd.exe /c wsl -d /usr/sbin/netdata-claim.sh -token=$token -rooms="$rooms" -url=$url -daemon-not-running 2>&1 | %{ "$_" }
	}
}
if ($telemetry -eq "0") {
	cmd.exe /c wsl -d netdata touch /etc/netdata/.opt-out-from-anonymous-statistics
}

Write-Output "STARTING AGENT"
cmd.exe /c wsl -d netdata netdata 2>&1 | %{ "$_" }

if (-Not (test-path installed)) {
	Write-Output "ADDING NETDATA TO STARTUP"
	New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name Netdata -Value 'wsl.exe -d Netdata netdata'

	Write-Output "REMOVING INSTALLATION LOGON TASK"
	schtasks.exe /delete /tn netdata /f

	Write-Output "SAVING INSTALLED FLAG"
	New-Item installed | Out-Null
}

Write-Output "INSTALLATION FINISHED"
