# 6.2 Creating and securing SMB shares
#
# Run from FS1


# 1. Ensure folder exists and install NTFS Security module
$EAHT = @{Erroraction = 'SilentlyContinue' }
New-Item -Path C:\Sales1 -ItemType Directory | Out-Null
Install-Module -Name NTFSSecurity -Force

# 2. Discover existing SMB shares on FS1
Get-SmbShare -Name * 

# 3. Create a new share Sales1
New-SmbShare -Name Sales1 -Path C:\Sales1

# 4. Set the share's Description
$CHT = @{Confirm = $False }
Set-SmbShare -Name Sales1 -Description 'Sales share on FS1' @CHT

# 5. Set folder enumeration mode
$CHT = @{Confirm = $false }
Set-SMBShare -Name Sales1 -FolderEnumerationMode AccessBased @CHT

# 6. Require encryption on data transmistted to/from the share
Set-SmbShare –Name Sales1 -EncryptData $true @CHT

# 7. Removing all access to Sales1 share for the Everyone group
$AHT1 = @{
  Name        = 'Sales1'
  AccountName = 'Everyone'
  Confirm     = $false
}
Revoke-SmbShareAccess @AHT1 | Out-Null

# 8. Adding Reskit\Domain Admins to the share
$AHT2 = @{
  Name        = 'Sales1'
  AccessRight = 'Read'
  AccountName = 'Reskit\Domain Admins'
  ConFirm     = $false 
} 
Grant-SmbShareAccess @AHT2 | Out-Null

# 9. Add system full access
$AHT3 = @{
  Name        = 'Sales1'
  AccessRight = 'Full'
  AccountName = 'NT Authority\SYSTEM'
  Confirm     = $False 
}
Grant-SmbShareAccess  @AHT3 | Out-Null

# 10. Set Creator/Owner to Full Access
$AHT4 = @{
  Name         = 'Sales1'
  AccessRight  = 'Full'
  AccountName  = 'CREATOR OWNER'
  Confirm      = $False 
}
Grant-SmbShareAccess @AHT4  | Out-Null


# 11. Grant Sales group change access
$AHT5 = @{
  Name        = 'Sales1'
  AccessRight = 'Change'
  AccountName = 'Sales'
  Confirm     = $false 
}
Grant-SmbShareAccess @AHT5 | Out-Null

# 12. Review Access to Sales1 share
Get-SmbShareAccess -Name Sales1 | 
  Sort-Object AccessRight

# 13. Review initial NTFS Permissions on the folder
Get-NTFSAccess -Path C:\Sales1 

# 14. Set the NTFS Permissions to match share
Set-SmbPathAcl -ShareName 'Sales1'

# 15. Removing NTFS Inheritance
Set-NTFSInheritance -Path C:\Sales1 -AccessInheritanceEnabled $False

# 16. View folder ACL using Get-NTFSAccess
Get-NTFSAccess -Path C:\Sales1 |
  Format-Table -AutoSize






# reset for testing

<# reset the shares 
Get-smbshare foo | remove-smbshare -Confirm:$false

#>
