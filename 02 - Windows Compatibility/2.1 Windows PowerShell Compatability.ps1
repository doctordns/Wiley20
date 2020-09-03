# 2.1 Windows PowerShell Compatability

# Run on CL1 and on DC1

# Start on CL1

# 1. Create a simple script module - MyModule1
$MyModulePath = "$env:USERPROFILE\Documents\PowerShell\Modules\MyModule1"
$MyModule = @"
# MyModule1.PSM1
Function Get-HelloWorld {
  "Hello World from My Module"
}
"@
New-Item  -Path $MyModulePath -ItemType Directory -Force | Out-Null
$MyModule | Out-File -FilePath $MyModulePath\MyModule1.PSM1 
Get-Module -Name MyModule1 -ListAvailable

# 2. Import the MyModule1 module
Import-Module -Name MyModule1 -Verbose

# 3. Create and Test a new module manifest
$NMMFHT = @{
  Path        = "$MyModulePath\MyModule1.PSD1"
  Author      = "Thomas Lee"
  CompanyName = 'PS Partnership'
  Rootmodule  = 'MyModule1.psm1' 
}
New-ModuleManifest @NMMFHT 
Get-Module -Name MyModule1 -List
# remove and re-import the module
Get-Module -Name MyModule1 | Remove-Module 
Import-Module -Name MyModule1 -Verbose
Get-HelloWorld

# 4. Create MyModule2 with 2 versions
# Create Module folders
$MyModule2Path   = 
  "$env:USERPROFILE\Documents\PowerShell\Modules\MyModule2"
$MyModule2V1Path = "$MyModule2Path\1.0.0"
$MyModule2V2Path = "$MyModule2Path\2.0.0"
New-Item -Path $MyModule2Path -ItemType Directory -Force | Out-Null
New-Item -Path $MyModule2Path -Name '1.0.0' -ItemType Directory -Force |
  Out-Null
New-Item -Path $MyModule2Path -Name '2.0.0' -ItemType Directory -Force |
  Out-Null
# Create MyModule2V1.PSM1
$MyModule2V1 = @"
Function Get-HelloWorld2 {
  "Hello World from MyModule2 (V1)"
}
"@
$MyModule2V1 | Out-File -Path "$MyModule2V1Path\MyModule2.PSM1"
# Create MyModule2V2.PSM1
$MyModule2V2 = @"
Function Get-HelloWorld2 {
  "Hello World from MyModule2 (V2)"
}
"@
$MyModule2V2 | Out-File -Path "$MyModule2V2Path\MyModule2.PSM1"
# Create manifests for both versions of this module
$NMMFHV1HT = @{
  Path        = "$MyModule2V1Path\MyModule2.PSD1"
  Author      = "Thomas Lee"
  CompanyName = 'PS Partnership'
  Rootmodule  = 'MyModule2.psm1' 
}
New-ModuleManifest @NMMFHV1HT -ModuleVersion '1.0.0'
$NMMFHV2HT = @{
  Path        = "$MyModule2V2Path\MyModule2.PSD1"
  Author      = "Thomas Lee"
  CompanyName = 'PS Partnership'
  Rootmodule  = 'MyModule2.psm1' 
}
New-ModuleManifest @NMMFHV2HT -ModuleVersion '2.0.0'

# 5. Use MyModule2
# Discover, import and use MyModule2
Get-Module MyModule2 -ListAvailable
Import-Module -Name MyModule2 -Verbose -RequiredVersion '1.0.0'
Get-HelloWorld2
# Re-import MyModule2 - by default the highest version
Import-Module -Name MyModule2 -Force -Verbose
# Use V2 Function
Get-HelloWorld2

# 6. Demonstrate autoload of MyModule2
Get-Module MyModule* | Remove-Module -Verbose
Get-HelloWorld2

# 7. View Module Analysis Cache
$CF = "$Env:LOCALAPPDATA\Microsoft\Windows\PowerShell\"+
      "ModuleAnalysisCache"  
Get-ChildItem -Path $CF

# Run on DC1

# 8. Import Server Manager Module on DC1 and use it
Get-Module ServerManager -ListAvailable
Import-Module ServerManager
Get-Module ServerManager | Format-Table -AutoSize -Wrap
Get-WindowsFeature -Name Hyper-V | Format-Table -AutoSize
$CS = Get-PSSession -Name WinPSCompatSession
Invoke-Command -Session $CS -ScriptBlock {
  Get-WindowsFeature -Name Hyper-V | Format-Table -AutoSize
}

# 9. View JSON Configuration File
Get-Content -Path $PSHOME\powershell.config.json
 
