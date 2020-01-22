# 1.4 - Creating an Internal PowerShell Repository
# 
# Run from SRV1 (SRV1.Reskit.Org)

# 1. Create Fepository Folder
$LPATH = 'C:\RKRepo'
New-Item -Path $LPATH -ItemType Directory | Out-Null

# 2. Share the Repository Folder
$SMBHT = @{
  Name        = 'RKRepo' 
  Path        = $LPATH 
  Description = 'Reskit Repopository'
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
Import-Module -Name C:\HW -verbose
GHW

# 6. Create a Module Manifest for this module
$NMHT = @{
  Path              = 'C:\HW\HW.psd1' 
  RootModule        = 'HW.psm1' 
  Description       = 'Hello World module' 
  Author            = 'DoctorDNS@Gmail.com' 
  FunctionsToExport =  'Get-HelloWorld'
}

# 7. Create the repository as trusted
#    Repeat on every host that uses this repository
$Path = '\\SRV1.Reskit.Org\RKRepo'
$REPOHT = @{
  Name               = 'RKRepo'
  SourceLocation     = $Path
  PublishLocation    = $Path
  InstallationPolicy = 'Trusted'
}
Register-PSRepository @REPOHT

# 8. View configured repositories
Get-PSRepository

# 9. Publish the module to thee repository
Publish-Module -Path C:\HW -Repository RKRepo

# 10. See Repo folder
Get-ChildItem -Path C:\RKRepo

# 11. Find the modujle in the RKRepo repository
Find-Module -Repository RKRepo
