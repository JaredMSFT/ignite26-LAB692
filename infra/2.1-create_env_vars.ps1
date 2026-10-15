<#
Create Environment Variables
Execute Script in Virtual Machine
Machine	Win11-Pro-Base
Language	PowerShell
Blocking	Yes
Timeout	5 Minutes
Retries	0
Error Action	Log
#>

$rgId = '@lab.CloudResourceGroup(ResourceGroup1).Name'
$hdbId = 'horizondb-@lab.LabInstance.GlobalId'

$user = '@lab.CloudPortalCredential(User1).Username'
$pass = '@lab.CloudPortalCredential(User1).Password'
$tenant = '@lab.CloudSubscription.TenantId'

$prev = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
& az login --username $user --password $pass --tenant $tenant
$code = $LASTEXITCODE
$ErrorActionPreference = $prev

if ($code -ne 0) { throw "az login failed with exit code $code" }

$prev = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$fqdn = az horizondb show --name $hdbId --resource-group $rgId --query "properties.fullyQualifiedDomainName" -o tsv
$code = $LASTEXITCODE
$ErrorActionPreference = $prev

if ($code -ne 0) { throw "az horizondb show failed with exit code $code" }

$projectDirectory = '@lab.Variable(LabResources)'
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
            user               = "@lab.VirtualMachine(Win11-Pro-Base).Username"
        }
    )
}

$json = $settings | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($settingsPath, $json, [System.Text.UTF8Encoding]::new($false))

$aiName = 'foundry-@lab.LabInstance.GlobalId'

$endpoint = az cognitiveservices account show --name $aiName --resource-group $rgId --query "properties.endpoint" -o tsv
$key = az cognitiveservices account keys list --name $aiName --resource-group $rgId --query "key1" -o tsv

$openAiSettings = [ordered]@{
    AZURE_OPENAI_ENDPOINT      = $endpoint
    AZURE_OPENAI_KEY           = $key
    AZURE_OPENAI_DEPLOYMENT    = "gpt-5.4"
    AZURE_EMBED_DEPLOYMENT     = "text-embedding-3-small"
    AZURE_RERANKER_DEPLOYMENT  = "Cohere-rerank-v4.0-fast"
    AZURE_API_VERSION          = "2026-03-05" # 1
}

$pgSettings = [ordered]@{
    AZURE_PG_HOST    = $fqdn
    AZURE_PG_NAME    = "postgres"
    AZURE_PG_USER    = "@lab.VirtualMachine(Win11-Pro-Base).Username"
    AZURE_PG_PASSWORD="@lab.VirtualMachine(Win11-Pro-Base).Password"
    AZURE_PG_PORT    = 5432
    AZURE_PG_SSLMODE = "require"
}

$content = @()

$content += "# Azure OpenAI"
$content += $openAiSettings.GetEnumerator() |
    ForEach-Object { "$($_.Key)=$($_.Value)" }

$content += ""
$content += "# Azure HorizonDB connection"
$content += $pgSettings.GetEnumerator() |
    ForEach-Object { "$($_.Key)=$($_.Value)" }

$envDirectory = Join-Path $projectDirectory 'src'
$settingsPath = Join-Path $envDirectory '.env'

$content | Set-Content -Path $settingsPath -Encoding utf8