Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -NoRestart -OutVariable results
if ($LASTEXITCODE) {	
	exit 1
}
if ($results.RestartNeeded -eq $true) {
	Restart-Computer -Force
	exit 1
}