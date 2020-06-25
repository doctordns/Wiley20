# 1.4 - Creating an Internal PowerShell Repository
# 
# Run from DC1

# 1. Create Repository Folder
$LPATH = 'C:\RKRepo'
New-Item -Path $LPATH -ItemType Directory | Out-Null

# 2. Share the Repository Folder
$SMBHT = @{
  Name        = 'RKRepo' 
  Path        = $LPATH 
  Description = 'Reskit Repository'
  FullAccess  = 'Everyone'
}
New-SmbShare @SMBHT

# 3. Create a Working Folder for a Module
New-Item C:\HW -ItemType Directory | Out-Null

# 4. Create a simple module
$HS = @'
Function Get-HelloWorld {'Hello World'}
Set-Alias GHW Get-HelloWorld
'@
$HS | Out-File C:\HW\HW.psm1

# 5. Load and Test the Module
Import-Module -Name C:\HW -Verbose
GHW

# 6. Create a Module Manifest for this module
$NMHT = @{
  Path              = 'C:\HW\HW.psd1' 
  RootModule        = 'HW.psm1' 
  Description       = 'Hello World module' 
  Author            = 'DoctorDNS@Gmail.com' 
  FunctionsToExport =  'Get-HelloWorld'
  ModuleVersion     = '1.0.0'
}
New-ModuleManifest @NMHT 

# 7. Create the repository as trusted
#    Repeat on every host that uses this repository
$Path = '\\DC1\RKRepo'
$REPOHT = @{
  Name               = 'RKRepo'
  SourceLocation     = $Path
  PublishLocation    = $Path
  InstallationPolicy = 'Trusted'
}
Register-PSRepository @REPOHT

# 8. View configured repositories
Get-PSRepository

# 9. Publish the module to the repository
Publish-Module -Path C:\HW -Repository RKRepo -Force 

# 10. View the repository folder
Get-ChildItem -Path C:\RKRepo

# 11. Find the module in the RKRepo repository
Find-Module -Repository RKRepo
