<#
First Displayable

Create VS Code PostgreSQL Connection for HorizonDB
Execute Script in VM
Language	PowerShell
Blocking	No
Timeout	10 Minutes
Retries	0
Error Action	Log
#>

$rgId = '@lab.CloudResourceGroup(ResourceGroup1).Name'
$hdbId = 'horizondb-@lab.LabInstance.GlobalId'

$fqdn = az horizondb show --name $hdbId --resource-group $rgId --query "properties.fullyQualifiedDomainName" -o tsv

$projectDirectory = 'C:\Users\LabUser\source\repos\ignite26-LAB692'
$vscodeDirectory = Join-Path $projectDirectory '.vscode'
$settingsPath = Join-Path $vscodeDirectory 'settings.json'

New-Item -ItemType Directory -Path $vscodeDirectory -Force | Out-Null

$settings = @{
    'pgsql.connections' = @(
        @{
            profileName        = 'Ignite Lab HorizonDB'
            server             = '$fqdn'
            port               = 5432
            database           = 'postgres'
            user               = 'LabUser'
            authenticationType = 'SqlLogin'
            sslmode            = 'require'
        }
    )
}

$json = $settings | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($settingsPath, $json, [System.Text.UTF8Encoding]::new($false))