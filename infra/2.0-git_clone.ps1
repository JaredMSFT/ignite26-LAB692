<#
Git Clone
Execute Script in Virtual Machine
Machine	Win11-Pro-Base
Language	Windows Command Shell
Blocking	Yes
Delay	60 Seconds
Timeout	5 Minutes
Retries	0
Error Action	Log
#>

# gh repo clone JaredMSFT/ignite26-LAB692

Set-Location C:\Users\LabUser\source\repos
git clone https://github.com/JaredMSFT/ignite26-LAB692.git