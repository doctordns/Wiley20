# Monitor.PS1
#
# Runs each time the permanent event handler fires

PARAM(
    [string] $Group
)

$LogFile   = 'C:\Foo\Grouplog.txt'
"On:  [$(Get-Date)]  Group [$Group] was changed to:" | 
  Out-File -Force $LogFile -Append
  $ADGm = Get-ADGroupMember -Identity $Group
  $ADGM | Format-Table name, distinguishedname | 
             Out-File -Force $LogFile -Append

If ($group = eq 'Enterprise Admins'
  $OKUsers = Get-Content c:\foo\okusers.txt
  foreach ($User in $ADGM) {
      if ($User.Name -notin $OKUsers) {
        "Unauthorised user added to $Group"  | 
          Out-File =Force $LogFile -Append
      }
  }

'**********************************`n`n' | Out-File -Force $LogFile -Append              
