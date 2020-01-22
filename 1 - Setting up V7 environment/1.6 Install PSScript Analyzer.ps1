# 1.6 Install PS Script Analyzer

# Run on CL1
# Needs to be run as administrator

# 1. Install Latest Version of Nuget Provider
Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Force

# 2. Install the script analyzer module
Install-Module -Name PSScriptAnalyzer -Force

# 3. Examine the module
Import-Module PSScriptAnalyzer
Get-Command -Module PSScriptAnalyzer

# 5. Get a script to analyse and save it locally
New-Item -Path c:\foo\scripts -Itemtype Directory | Out-Null
Save-Script -Name Check-Spelling -Path C:\Foo\Scripts
Get-ChildItem -Path C:\Foo\Scripts

# 7. Check the script
Invoke-ScriptAnalyzer -Path C:\Foo\Scripts\Check-Spelling.ps1 -ExcludeRule PSAvoidTrailingWhitespace
  Format-Table -AutoSize
 
