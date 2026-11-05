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

$target = '@lab.Variable(LabResources)'

if (Test-Path -LiteralPath $target) {
    Remove-Item -LiteralPath $target -Recurse -Force -ErrorAction Stop
}

New-Item -ItemType Directory -Force (Split-Path $target) -ErrorAction Stop | Out-Null

$prev = $ErrorActionPreference
try {
    $ErrorActionPreference = 'Continue'
    & git clone --quiet https://github.com/JaredMSFT/ignite26-LAB692.git "$target"
    $code = $LASTEXITCODE

    if ($code -ne 0) { throw "git clone failed with exit code $code" }
}
finally {
    $ErrorActionPreference = $prev
}
