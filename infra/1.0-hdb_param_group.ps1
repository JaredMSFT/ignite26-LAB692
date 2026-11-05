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
$rgName = '@lab.CloudResourceGroup(ResourceGroup1).Name'
$hdbName = 'horizondb-@lab.LabInstance.GlobalId'
$hdbParamsName = "$hdbName-parameters"

$parameterGroupId = "/subscriptions/$subId/resourceGroups/$rgName/providers/Microsoft.HorizonDb/parameterGroups/$hdbParamsName"

az horizondb update --name $hdbName --resource-group $rgName --parameter-group $parameterGroupId