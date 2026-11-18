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
$poolName = 'defaultpool'
$hdbParamsName = "$hdbName-parameters"

$parameterGroupId = "/subscriptions/$subId/resourceGroups/$rgName/providers/Microsoft.HorizonDb/parameterGroups/$hdbParamsName"
$poolId = "/subscriptions/$subId/resourceGroups/$rgName/providers/Microsoft.HorizonDb/clusters/$hdbName/pools/$poolName"

az config set extension.dynamic_install_allow_preview=true --only-show-errors
az extension add --name horizondb --allow-preview true --upgrade --only-show-errors

az horizondb cluster pool update --resource-group $rgName --cluster-name $hdbName --pool-name $poolName --parameter-group-resource-id $parameterGroupId --only-show-errors --output none
if ($LASTEXITCODE -ne 0) { throw "pool update failed with exit code $LASTEXITCODE" }

$deadline = (Get-Date).AddMinutes(10)
do {
    Start-Sleep -Seconds 15
    $sync = az rest --method get --url "https://management.azure.com${poolId}?api-version=2026-10-01-preview" --query properties.parameterGroup.syncStatus --output tsv
} until ($sync -eq 'InSync' -or (Get-Date) -gt $deadline)
if ($sync -ne 'InSync') { throw "parameter group not in sync: $sync" }