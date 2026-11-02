<#
pip upgrade
Execute Script in Virtual Machine
Machine	Win11-Pro-Base
Language	PowerShell
Blocking	Yes
Timeout	10 Minutes
Retries	0
Error Action	Log
#>

$prev = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
& py -3.11 -m ensurepip --upgrade
$code = $LASTEXITCODE
$ErrorActionPreference = $prev

if ($code -ne 0) { throw "pip upgrade failed with exit code $code" }