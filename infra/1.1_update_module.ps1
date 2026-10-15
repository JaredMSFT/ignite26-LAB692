<#
Add HorizonDB Firewall Rule
Execute Script in Virtual Machine
Machine	Win11-Pro-Base
Language	PowerShell
Blocking	Yes
Delay	0 Seconds
Timeout	5 Minutes
Retries	0
Error Action	Log
#>

$zip  = Join-Path $env:TEMP 'azure-cli.zip'
$dest = Join-Path $env:USERPROFILE 'AzureCLI'

Invoke-WebRequest -Uri 'https://aka.ms/installazurecliwindowszipx64' -OutFile $zip
if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
Expand-Archive -Path $zip -DestinationPath $dest -Force
Remove-Item $zip

# Put it ahead of the old CLI on this session and on the user PATH
$bin = Join-Path $dest 'bin'
$env:Path = "$bin;$env:Path"
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
[Environment]::SetEnvironmentVariable('Path', "$bin;$userPath", 'User')

az extension add --upgrade -n horizondb --yes