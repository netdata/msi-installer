Write-Output "STARTING UNINSTALL SCRIPT"

if (-Not (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq "Enabled") {
	Write-Output "WSL FEATURE IS NOT INSTALLED, WONT UNREGISTER DISTRO"	
} else {
	Write-Output "UNREGISTERING NETDATA WSL DISTRO"
	# running unregister-netdata.cmd through explorer.exe
	# so it runs as the current user and not LocalSystem
	explorer.exe unregister-netdata.cmd
}

Write-Output "CHECKING FOR INSTALLATION LOGON TASK"
if (Get-ScheduledTask -TaskName Netdata -ErrorAction SilentlyContinue) {
	Write-Output "REMOVING INSTALLATION LOGON TASK"
	cmd.exe /c schtasks.exe /delete /tn netdata /f
} else {
    Write-Output "INSTALLATION LOGON TASK NOT FOUND"
}

Write-Output "REMOVING VERSION FILE"
Remove-Item version.txt
if (test-path restart) {
	Write-Output "REMOVING RESTART FLAG FILE"
	Remove-Item restart -ErrorAction SilentlyContinue
}

Write-Output "REMOVING SAVED CLOUD INSTALLATION FILES"
Remove-Item *.txt

Write-Output "REMOVING STARTUP FROM REGISTRY"
explorer.exe remove-startup.cmd

Write-Output "REMOVING FIREWALL RULE FOR WSL1 IF EXISTS"
if (Get-NetFirewallRule -DisplayName netdata -ErrorAction SilentlyContinue) {
	Remove-NetFirewallRule -DisplayName netdata
}

Write-Output "REMOVING NETDATA_WSL_VERSION SYS ENV VAR"
REG delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /F /V NETDATA_WSL_VERSION

Write-Output "REMOVING NETDATA FOLDER FROM PATH"
do {
	$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
	Write-Output "PREVIOUS PATH:"
	$oldpath
	$newpath = $oldpath -replace [regex]::escape(";C:\Netdata")
	$newpath = $newpath -replace [regex]::escape(";c:\program files (x86)\netdata")
	cmd.exe /c setx /m PATH "$newpath"	
	$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
} while (($oldpath -like "*;C:\Netdata*") -or ($oldpath -like "*;c:\program files (x86)\netdata*"));
$currentpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
Write-Output "CURRENT PATH:"
$currentpath

Write-Output "REMOVING INSTALLED FLAG"
Remove-Item installed

Write-Output "UNINSTALLATION SCRIPT FINISHED"
