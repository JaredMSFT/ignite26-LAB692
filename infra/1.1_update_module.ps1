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



az version
az upgrade --yes
az version

winget install --exact --id Microsoft.AzureCLI

az extension remove --name horizondb
az extension add --name horizondb --allow-preview true

# az extension add --upgrade -n horizondb --yes