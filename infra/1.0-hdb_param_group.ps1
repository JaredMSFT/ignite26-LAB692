<#
First Displayable
Apply HorizonDB Parameter Group
Execute Script in Cloud Platform
Language	PowerShell
Version	PS 7.6.2 | Azure-CLI 2.86.0
Blocking	Yes
Timeout	20 Minutes
Retries	0
Error Action	Log
#>

$subId = '@lab.CloudSubscription.Id'
$rgId = '@lab.CloudResourceGroup(ResourceGroup1).Name'
$hdbId = 'horizondb-@lab.LabInstance.GlobalId'
$hdbparamsId = "$hdbId-parameters"

$parameterGroupId = "/subscriptions/$subId/resourceGroups/$rgId/providers/Microsoft.HorizonDb/parameterGroups/$hdbparamsId"

az horizondb update --name $hdbId --resource-group $rgId --parameter-group $parameterGroupId