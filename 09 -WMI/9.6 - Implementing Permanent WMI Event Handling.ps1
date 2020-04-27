# 9.6 Create permanent event handler

# Run on DC1

# 1. Create a list of valid users for Enterprise Admins
$LogFile   = 'C:\Foo\GroupLog.Txt'
$OKUsers =  'Administrator'
$OKUsers | Out-File -FilePath $LogFile

# 2. Define two helper functions
Function Get-WMIPE {
  '***Event Filters Defined:'
    Get-CimInstance -Namespace root\subscription -ClassName __EventFilter  |
      Where Name -eq "EventFilter1" |
       Format-Table Name, Query
  '***Consumer Defined:'
    Get-CimInstance -NameSpace root\subscription -classname CommandLineEventConsumer |
      Where {$_.name -eq "EventConsumer1"}  |
       Format-Table Name, Commandlinetemplate
  '***Bindings Defined:'
    Get-CimInstance -Namespace root\subscription -ClassName __FilterToConsumerBinding |
      Where-Object -FilterScript {$_.Filter.Name -eq "EventFilter1"} |
        Format-Table Filter, Consumer
  }
  Function Remove-WMIPE {
  Get-CimINstance -Namespace root\subscription __EventFilter | 
    Where-Object Name -eq "EventFilter1" |
      Remove-CimInstance
  Get-CimInstance -Name root\subscription CommandLineEventConsumer | 
    Where-Object Name -eq 'EventConsumer1' |
      Remove-CimInstance
  Get-CimInstance -Name root\subscription __FilterToConsumerBinding  |
    Where-Object -FilterScript {$_.Filter.Name -eq 'EventFilter1'}   |
      Remove-CimInstance
  }
Set-Alias -Name sh -Value Get-WMIPE
Set-Alias -name de -Value Remove-WMIPE

# 3. Create an event filter query
$Group = 'Enterprise Admins'
$Query = @"
  Select * From __InstanceModificationEvent Within 10  
   Where TargetInstance ISA 'ds_group' AND 
         TargetInstance.ds_name = '$Group'
"@

# 4. Create an event filter
$Param = @{
  QueryLanguage =  'WQL'
  Query          =  $Query
  Name           =  "EventFilter1"
  EventNameSpace =  "root/directory/LDAP"
}
$IHT = @{
  ClassName = '__EventFilter'
  Namespace = 'root/subscription'
  Property  = $param
}        
$InstanceFilter = New-CimInstance @IHT

# 5. Create Monitor.PS1 that is to run each time
#    the Enterprise Admin group membership changes
$MONITOR = @'
$LogFile   = 'C:\Foo\Grouplog.Txt'
$Group     = 'Enterprise Admins'
"On:  [$(Get-Date)]  Group [$Group] was changed" | 
  Out-File -Force $LogFile -Append -Encoding Ascii
$ADGM = Get-ADGroupMember -Identity $Group
# Display who's in the group
$ADGM | Format-Table Name, DistinguishedName |
  Out-File -Force $LogFile -Append  -Encoding Ascii
$OKUsers = Get-Content -Path C:\Foo\OKUsers.txt
# Look at who is not authroized
foreach ($User in $ADGM) {
  if ($User.Name -notin $OKUsers) {
    "Unauthorised user [$($User.Name)] added to $Group"  | 
      Out-File -Force $LogFile -Append  -Encoding Ascii
  }
}
"**********************************`n`n" | 
Out-File -Force $LogFile -Append -Encoding Ascii
'@
$MONITOR | Out-File -Path C:\Foo\Monitor.ps1

# 6. Create an  Event Consumer
#    The consumer runs PowerShell 7 to execute C:\Foo\Monitor.ps1" 
$CLT = 'Pwsh.exe -File C:\Foo\Monitor.ps1'
$Param =[ordered] @{
   Name                = 'EventConsumer1'
   CommandLineTemplate = $CLT
}
$ECHT = @{
  Namespace = 'root/subscription'
  ClassName = "CommandLineEventConsumer"
  Property  = $param
}        
$InstanceConsumer = New-CimInstance @ECHT

# 7. Bind the filter and consumer
$Param = @{
           Filter   = [ref]$InstanceFilter     
           Consumer =[ref]$InstanceConsumer
          }
$IBHT = @{
    Namespace = 'root/subscription'
    ClassName = '__FilterToConsumerBinding'
    Property  = $Param
}
$InstanceBinding= New-CimInstance   @IBHT

# 8. Get the event filter details
Get-WMIPE  

# 9. Add a user to the enterprise admin group
Add-ADGroupMember -Identity 'Enterprise admins' -Members Sylvester

# 10. View Grouplog.txt file
Get-Content -File C:\Foo\Grouplog.txt

# 11. Tidy up
Remove-WMIPE
Remove-ADGroupMember -identity 'enterprise admins' -Member 'sylvester' -Confirm:$false
Get-WMIPE

