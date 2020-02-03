# Recipe 6.4 - Creating and securing SMB shares
#
# Run from SRV1

# 0 Just in case
$EAHT = @{Erroraction = 'SilentlyContinue' }
New-Item -Path c:\Foo -ItemType Directory @EAHT

# 1. Discover existing shares and access rights
Get-SmbShare -Name * |
  Where-Object Name -NotMatch '\$$'

# 2. Ensure folder exists and then share the foler
$EAHT = @{Erroraction = 'SilentlyContinue' }
New-Item -Path c:\Foo -ItemType Directory @EAHT
New-SmbShare -Name Foo -Path C:\Foo

# 3. eUpdate the share to have a description
$CHT = @{Confirm = $False }
Set-SmbShare -Name Foo -Description 'Foo share for IT' @CHT

# 4. Setting folder enumeration mode
$CHT = @{Confirm = $false }
Set-SMBShare -Name Foo -FolderEnumerationMode AccessBased @CHT

# 5. Setting encryption on for Foo share
Set-SmbShare –Name Foo -EncryptData $true @CHT

# 6. Removing all access to Foo share
$AHT1 = @{
  Name        = 'Foo'
  AccountName = 'Everyone'
  Confirm     = $false
}
Revoke-SmbShareAccess @AHT1 | Out-Null

# 7. Adding Reskit\Administrators to the share
$AHT2 = @{
  Name        = 'Foo'
  AccessRight = 'Read'
  AccountName = 'Reskit\ADMINISTRATOR'
  ConFirm     = $false 
} 
Grant-SmbShareAccess @AHT2 | Out-Null

# 8. Add system full access
$AHT3 = @{
  Name        = 'foo'
  AccessRight = 'Full'
  AccountName = 'NT Authority\SYSTEM'
  Confirm     = $False 
}
Grant-SmbShareAccess  @AHT3 | Out-Null

# 9. Granting Sales Team read access, SalesAdmins has Full access
$AHT5 = @{
  Name        = 'Foo'
  AccessRight = 'Read'
  AccountName = 'Sales'
  Confirm     = $false 
}
Grant-SmbShareAccess @AHT5 | Out-Null

# 10. Review Foo share access
Get-SmbShareAccess -Name Foo | 
  Sort-Object AccessRight

# 11. Review NTFS Permissions on the folder
Install-Module NTFSSecurity -Force # just in case
Get-NTFSAccess -Path C:\Foo   

# 12. Set the NTFS Permissions to match share
Set-SmbPathAcl -ShareName 'Foo'# 13. Remove NTFS Inheritance

# 13. Removing NTFS Inheritance
Set-NTFSInheritance -Path C:\Foo -AccessInheritanceEnabled:$False

# 14. View folder ACL using Get-NTFSAccess
Get-NTFSAccess -Path C:\Foo | 
  Format-Table -AutoSize




# reset for testing

<# reset the shares 
Get-smbshare foo | remove-smbshare -Confirm:$false

#>
