# 3.5 - Creating and managing AD users, groups, and computers

# Run on DC1

# 1. Create a hash table for general user attributes
$PW  = 'Pa$$w0rd'
$PSS = ConvertTo-SecureString -String $PW -AsPlainText -Force
$NewUserHT = @{
  AccountPassword       = $PSS
  Enabled               = $true
  PasswordNeverExpires  = $true
  ChangePasswordAtLogon = $false
}

# 2. Create two users - adding to basic hash table
# First user
$NewUserHT.SamAccountName    = 'ThomasL'
$NewUserHT.UserPrincipalName = 'ThomasL@reskit.Org'
$NewUserHT.Name              = 'ThomasL'
$NewUserHT.DisplayName       = 'Thomas Lee (IT)'
New-ADUser @NewUserHT  # add first user
# Second user
$NewUserHT.SamAccountName    = 'RLT'
$NewUserHT.UserPrincipalName = 'RLT@Reskit.org'
$NewUserHT.Name              = 'Rebecca Lee-Tanner'
$NewUserHT.DisplayName       = 'Rebecca Lee-Tanner (IT)'
New-ADUser @NewUserHT  # Add second user

# 3. Create an Organizational Unit for IT
$OUHT = @{
  Name        = 'IT'
  DisplayName = 'Reskit IT Team'
  Path        = 'DC=Reskit,DC=Org'
}
New-ADOrganizationalUnit @OUHT

# 4. Move the two users into the OU
$MHT1 = @{
  Identity   = 'CN=ThomasL,CN=Users,DC=Reskit,DC=ORG'
  TargetPath = 'OU=IT,DC=Reskit,DC=Org'
}
Move-ADObject @MHT1
$MHT2 = @{
  Identity = 'CN=Rebecca Lee-Tanner,CN=Users,DC=Reskit,DC=ORG'
  TargetPath = 'OU=IT,DC=Reskit,DC=Org'
}
Move-ADObject @MHT2

# 5. Create a third user directly in the IT OU
$NewUserHT.SamAccountName    = 'JerryG'
$NewUserHT.UserPrincipalName = 'jerryg@reskit.org'
$NewUserHT.Description       = 'Virtualization Team'
$NewUserHT.Name              = 'Jerry Garcia'
$NewUserHT.DisplayName       = 'Jerry Garcia (IT)'
$NewUserHT.Path              = 'OU=IT,DC=Reskit,DC=Org'
$NewUserHT.PasswordNeverExpires  = $true
$NewUserHT.ChangePasswordAtLogon = $false
New-ADUser @NewUserHT

# 6. Add two users who will then be removed
# First user to be removed
$NewUserHT.SamAccountName    = 'TBR1'
$NewUserHT.UserPrincipalName = 'tbr@reskit.org'
$NewUserHT.Name              = 'TBR1'
$NewUserHT.DisplayName       = 'User to be removed'
$NewUserHT.Path              = 'OU=IT,DC=Reskit,DC=Org'
New-ADUser @NewUserHT
# Second user to be removed
$NewUserHT.SamAccountName     = 'TBR2'
$NewUserHT.UserPrincipalName  = 'tbr2@reskit.org'
$NewUserHT.Name               = 'TBR2'
New-ADUser @NewUserHT

# 7. See the users that exist so far
Get-ADUser -Filter * -Properties DisplayName | 
  Format-Table -Property Name, DisplayName, SamAccountName

# 8. Remove via a Get | Remove Paterm
Get-ADUser -Identity 'CN=TBR1,OU=IT,DC=Reskit,DC=Org' |
    Remove-ADUser -Confirm:$false

# 9. Remove user directly 
$RUHT = @{
  Identity = 'CN=TBR2,OU=IT,DC=Reskit,DC=Org'
  Confirm  = $false}
Remove-ADUser @RUHT

# 10. Update and display a user
$TLHT =@{
  Identity     = 'ThomasL'
  OfficePhone  = '4416835420'
  Office       = 'Marin Office'
  EmailAddress = 'ThomasL@Reskit.Org'
  GivenName    = 'Thomas'
  Surname      = 'Lee' 
  HomePage     = 'Https://tfl09.blogspot.com'
}
Set-ADUser @TLHT
Get-ADUser -Identity ThomasL -Properties  DisplayName, Office,
                                          OfficePhone, EmailAddress  |
  Format-Table -Property DisplayName, Name, Office,
                         OfficePhone, EmailAddress 

# 11. Create a new group for RK DNS Admins
$NGHT1 = @{
 Name        = 'RKDnsAdmins'
 Path        = 'OU=IT,DC=Reskit,DC=org'
 Description = 'Reskit DNS Universal admins'
 GroupScope  = 'Universal'
}
New-ADGroup @NGHT1

# 12. Add a user to the DNS Admins group and view group members
Add-ADGroupMember -Identity 'RKDnsAdmins' -Members 'JerryG' | Out-Null
Get-ADGroupMember -Identity 'RKDnsAdmins'

# 13. Make a group for the IT Team
$NGHT2 = @{
  Name        = 'IT Team'
  Path        = 'OU=IT,DC=Reskit,DC=org'
  Description = 'All members of the IT Team'
  GroupScope  = 'Universal'
 }
 New-ADGroup @NGHT2
 
# 14. Make all Users in IT a Member Of This Group
$SB = 'OU=IT,DC=Reskit,DC=Org'
$ItUsers = Get-ADUser -Filter * -SearchBase $SB
Add-ADGroupMember -Identity 'IT Team' -Members $ItUsers

# 15. Display Group Members of the IT Team Group
Get-ADGroupMember -Identity 'IT Team' | 
  Format-Table -Property SamAccountName, DistinguishedName

# 16. Add a computer to the AD
$NCHT = @{
  Name                   = 'Wolf' 
  DNSHostName            = 'Wolf.Reskit.Org'
  Description            = 'One for Jerry'
  Path                   = 'OU=IT,DC=Reskit,DC=Org'
  OperatingSystemVersion = 'Windows Server 2019 Data Center'
}
New-ADComputer @NCHT

# 17. See the computer accounts
Get-ADComputer -Filter * -Properties DNSHostName,LastLogonDate | 
  Format-Table -Property Name, DNSHostName,LastLogonDate
