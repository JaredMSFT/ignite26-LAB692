<#
Git Clone
Execute Script in Virtual Machine
Machine	Win11-Pro-Base
Language	PowerShell
Blocking	Yes
Timeout	5 Minutes
Retries	0
Error Action	Log
#>

# gh repo clone JaredMSFT/ignite26-LAB692

<#
New-Item -ItemType Directory -Force C:\temp | Out-Null
Start-Transcript C:\temp\clone.log
git clone -v https://github.com/JaredMSFT/ignite26-LAB692.git C:\Users\LabUser\source\repos\ignite26-LAB692
"exit code: $LASTEXITCODE"
Stop-Transcript
#>

$target = 'C:\Users\LabUser\source\repos\ignite26-LAB692'

if (-not (Test-Path "$target\.git")) {
    New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null

    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & git clone --quiet https://github.com/JaredMSFT/ignite26-LAB692.git $target
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prev

    if ($code -ne 0) { throw "git clone failed with exit code $code" }
}