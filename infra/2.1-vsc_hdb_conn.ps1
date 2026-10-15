<#
Create VS Code Connection
Execute Script in Virtual Machine
Machine	Win11-Pro-Base
Language	PowerShell
Blocking	No
Delay	120 Seconds
Timeout	5 Minutes
Retries	0
Error Action	Log
#>

$rgId = '@lab.CloudResourceGroup(ResourceGroup1).Name'
$hdbId = 'horizondb-@lab.LabInstance.GlobalId'

$user = '@lab.CloudPortalCredential(User1).Username'
$pass = '@lab.CloudPortalCredential(User1).Password'
$tenant = '@lab.CloudSubscription.TenantId'

az login --username $user --password $pass --tenant $tenant

$fqdn = az horizondb show --name $hdbId --resource-group $rgId --query "properties.fullyQualifiedDomainName" -o tsv

$projectDirectory = 'C:\Users\LabUser\source\repos\ignite26-LAB692'
$vscodeDirectory = Join-Path $projectDirectory '.vscode'
$settingsPath = Join-Path $vscodeDirectory 'settings.json'

New-Item -ItemType Directory -Path $vscodeDirectory -Force | Out-Null

$settings = @{
    "pgsql.connections" = @(
        @{
            authenticationType = "SqlLogin"
            database           = "postgres"
            port               = 5432
            profileName        = "Ignite Lab HorizonDB"
            server             = "$fqdn"
            sslmode            = "require"
            user               = "LabUser"
        }
    )
}

$json = $settings | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($settingsPath, $json, [System.Text.UTF8Encoding]::new($false))