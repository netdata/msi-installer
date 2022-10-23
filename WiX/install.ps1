Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -NoRestart -OutVariable results
if ($LASTEXITCODE) {	
	exit 1
}
if ($results.RestartNeeded -eq $true) {
	Restart-Computer -Force
	exit 1
}
Remove-NetFirewallRule -DisplayName netdata
New-NetFirewallRule -Program C:\NetdataWSL\rootfs\usr\sbin\netdata -Action Allow -Profile Domain,Private,Public -DisplayName netdata -Description netdata -Direction Inbound
rm token.txt
if ($args[0] -ne "0") {
	$args[0] | out-file -encoding ascii -nonewline token.txt
}