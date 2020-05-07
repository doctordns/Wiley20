# 5.2 - Managing NTFS Permissions
# 
# Run on SRV1 - after  5.1 and adding/formatting 2 new disks.

# 1. Download NTFSSecurity module from PSGallery
Install-Module -Name NTFSSecurity -Force
Import-Module ServerManager -WarningAction SilentlyContinue
Install-WindowsFeature -Name RSAT-AD-Tools -IncludeAllSubFeature |
  Out-Null

# 2. Get commands in the module
Get-Command -Module NTFSSecurity  

# 3. Create a new folder, and a file in the folder
New-Item -Path C:\Secure1 -ItemType Directory |
    Out-Null
'Secure' | Out-File -FilePath C:\Secure1\Secure.Txt
Get-ChildItem -Path C:\Secure1

# 4. View ACL of the folder
Get-NTFSAccess -Path C:\Secure1 |
  Format-Table -AutoSize

# 5. View ACL of file
Get-NTFSAccess -Path C:\Secure1\Secure.Txt |
  Format-Table -AutoSize


# 6. Create Sales group if it does not exist
try {
  Get-ADGroup -Identity 'Sales' -ErrorAction Stop 
}
catch {
  New-ADGroup -Name Sales -GroupScope Universal  |
    Out-Null
}

# 7. Displaying the Sales Group
Get-ADGroup -Identity Sales


# 8. Adding explicit full control for Domain Admins
$AHT1 = @{
  Path         = 'C:\Secure1'
  Account      = 'Reskit\Domain Admins' 
  AccessRights = 'FullControl'
}
Add-NTFSAccess @AHT1

# 9. Remove Builtin\Users access from Secure.Txt file
$AHT2 = @{
  Path         = 'C:\Secure1\Secure.Txt'
  Account      = 'Builtin\Users' 
  AccessRights = 'FullControl'
}

Remove-NTFSAccess @AHT2

# 10. Remove inherited rights for the folder
$IRHT1 = @{
  Path                       = 'C:\Secure1'
  RemoveInheritedAccessRules = $True
}
Disable-NTFSAccessInheritance @IRHT1

# 11. Add Sales group access to the folder
$AHT3 = @{
  Path         = 'C:\Secure1\'
  Account      = 'Reskit\Sales' 
  AccessRights = 'FullControl'
}
Add-NTFSAccess @AHT3

# 12. Get ACL of folder
Get-NTFSAccess -Path C:\Secure1 |
  Format-Table -AutoSize

# 13. Get ACL of the file
Get-NTFSAccess -Path C:\Secure1\Secure.Txt |
  Format-Table -AutoSize


