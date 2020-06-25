# 10.1 - Reporting on AD Users

# Run on DC1

# 1. Define a function Get-ReskitUser
#    The function returns objects related to users in reskit.org
Function Get-ReskitUser {
  # Get PDC Emulator DC
  $PrimaryDC = Get-ADDomainController -Discover -Service PrimaryDC
  # Get Users
  $P       = "DisplayName","Office","LastLogonDate","BadPWDCount"
  $ADUsers = Get-ADUser -Filter * -Properties $P -Server $PrimaryDC

  # Iterate through them and create $Userinfo hash table:
  Foreach ($ADUser in $ADUsers) {
    # Create a userinfo HT
    $UserInfo = [Ordered] @{}
    $UserInfo.SamAccountName = $ADUser.SamAccountName
    $Userinfo.DisplayName    = $ADUser.DisplayName
    $UserInfo.Office         = $ADUser.Office
    $Userinfo.Enabled        = $ADUser.Enabled
    $Userinfo.LastLogonDate  = $ADUser.LastLogonDate
    $UserInfo.BadPWDCount    = $ADUser.BadPwdCount
    New-Object -TypeName PSObject -Property $UserInfo
  }
 } # end of function

# 2. Get the users
$RKUsers = Get-ReskitUser

# 3. Build the report header
$RKReport = '' # Define initial report variable
$RKReport += "*** Reskit.Org AD Report`n"
$RKReport += "*** Generated [$(Get-Date)]`n"
$RKReport += "*******************************`n`n"

# 4. Report on Disabled users
$RKReport += "*** Disabled Users`n"
$RKReport += $RKUsers |
    Where-Object {$_.Enabled -ne $true} |
        Format-Table -Property SamAccountName, DisplayName |
            Out-String

# 5. Report users who have not recently logged on
$OneWeekAgo = (Get-Date).AddDays(-7)
$RKReport += "`n*** Users Not logged in since $OneWeekAgo`n"
$RKReport += $RKUsers |
    Where-Object {$_.Enabled -and $_.LastLogonDate -le $OneWeekAgo} |
        Sort-Object -Property LastlogonDate |
            Format-Table -Property SamAccountName,lastlogondate |
                Out-String

# 6. Users with high invalid password attempts
#
$RKReport += "`n*** High Number of Bad Password Attempts`n"
$RKReport += $RKUsers | Where-Object BadPwdCount -ge 5 |
  Format-Table -Property SamAccountName, BadPWDCount |
    Out-String

# 7. Query the Enterprise Admins/Domain Admins/Schema Admins
#    groups for members and add to the $PUsers array
# Get Enterprise Admins group members
$RKReport += "`n*** Privileged  User Report`n"
$PUsers = @()
$Members =
  Get-ADGroupMember -Identity 'Enterprise Admins' -Recursive |
    Sort-Object -Property Name
$PUsers += foreach ($Member in $Members) {
  Get-ADUser -Identity $Member.SID -Properties * |
    Select-Object -Property Name,
                  @{Name='Group';Expression={'Enterprise Admins'}},
                  WhenCreated,LastLogonDate
}
# Get Domain Admins group members
$Members = 
  Get-ADGroupMember -Identity 'Domain Admins' -Recursive |
    Sort-Object -Property Name
$PUsers += Foreach ($Member in $Members) {
  Get-ADUser -Identity $Member.SID -Properties * |
    Select-Object -Property Name,
                  @{Name='Group';Expression={'Domain Admins'}},
                  WhenCreated, LastLogondate
}
# Get Schema Admins members
$Members = 
  Get-ADGroupMember -Identity 'Schema Admins' -Recursive |
    Sort-Object -Property Name
$PUsers += Foreach ($Member in $Members) {
  Get-ADUser -Identity $Member.SID -Properties * |
    Select-Object -Property Name,
                  @{Name='Group';Expression={'Schema Admins'}}, `
                WhenCreated, LastLogonDate
}

# 8. Add the special users to the report
$RKReport += $PUsers | Out-String

# 9. Display the report
$RKReport