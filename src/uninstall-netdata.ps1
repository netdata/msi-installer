Write-Output "STARTING UNINSTALL SCRIPT"
Write-Output "UNREGISTERING NETDATA WSL DISTRO"
explorer.exe unregister-netdata.cmd
Write-Output "CHECKING FOR INSTALLATION LOGON TASK"
cmd.exe /c schtasks /query /tn netdata
if (-Not $LASTEXITCODE) {
	Write-Output "REMOVING INSTALLATION LOGON TASK"
	cmd.exe /c schtasks.exe /delete /tn netdata /f
} else {
    Write-Output "INSTALLATION LOGON TASK NOT FOUND"
}
Write-Output "REMOVING INSTALLED FLAG FILE"
Remove-Item installed
Write-Output "REMOVING VERSION FILE"
Remove-Item version
if (test-path restart) {
	Write-Output "REMOVING RESTART FLAG FILE"
	Remove-Item restart -ErrorAction SilentlyContinue
}
Write-Output "REMOVING SAVED CLOUD CONFIGURATION FILES"
Remove-Item *.txt
Write-Output "REMOVING STARTUP FROM REGISTRY"
explorer.exe remove-startup.cmd
Write-Output "REMOVING FIREWALL RULE FOR WSL1"
Remove-NetFirewallRule -DisplayName netdata
Write-Output "UNINSTALLATION SCRIPT FINISHED"