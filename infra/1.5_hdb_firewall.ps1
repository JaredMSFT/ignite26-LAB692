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

az horizondb firewall-rule create --resource-group $rgId --cluster-name $hdbId --name 'Lab VM' --start-ip-address $ip --end-ip-address $ip