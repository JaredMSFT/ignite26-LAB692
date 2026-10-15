<#
pip install requirements
Execute Script in Virtual Machine
Machine	Win11-Pro-Base
Language	PowerShell
Blocking	No
Timeout	10 Minutes
Retries	0
Error Action	Log
#>

$target = '@lab.Variable(LabResources)'

$prev = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
& py -3.11 -m pip install -r "$target/src/requirements.txt"
$code = $LASTEXITCODE
$ErrorActionPreference = $prev

if ($code -ne 0) { throw "pip install failed with exit code $code" }