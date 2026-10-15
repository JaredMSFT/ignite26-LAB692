<#
Add HorizonDB Firewall Rule
Execute Script in Virtual Machine
Machine	Win11-Pro-Base
Language	PowerShell
Blocking	No
Delay	120 Seconds
Timeout	5 Minutes
Retries	0
Error Action	Log
#>

$ip = (Invoke-RestMethod -Uri 'https://api.ipify.org').Trim()
$rgId = 'ResourceGroup1'
$hdbId = 'horizondb-@lab.LabInstance.GlobalId'

winget upgrade --id Microsoft.AzureCLI --silent --accept-source-agreements --accept-package-agreements --disable-interactivity
az upgrade --yes --all true

az extension add --upgrade -n horizondb --yes

az login --username '@lab.CloudPortalCredential(User1).Username' --password '@lab.CloudPortalCredential(User1).Password'

az horizondb firewall-rule create --resource-group $rgId --cluster-name $hdbId --name 'Lab VM' --start-ip-address $ip --end-ip-address $ip