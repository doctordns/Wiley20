# 9.5 Managing WMI EVents

# Run in DC1
# Intrinsic, extrinsic, event (temp), event (permanent)

# 1. Simple intrinsic event
$Query1 = "SELECT * FROM __InstanceCreationEvent WITHIN 2 
          WHERE TargetInstance ISA 'Win32_Process'"
$CEHT = @{
  Query            = $Query1
  SourceIdentifier = 'NewProcessEvent'
}          
Register-CimIndicationEvent @CEHT

# 2. Run Notepad
notepad.exe

# 3. Get Event
$Event = Get-Event -SourceIdentifier 'NewProcessEvent' | 
           Select-Object -Last 1

# 4. Display event details
$Event.SourceEventArgs.NewEvent.TargetInstance

# 5. Unregister Event
Unregister-Event -SourceIdentifier 'NewProcessEvent'

# 6. Create and Register Extrinsic event query- handled by provider
New-Item -Path 'HKLM:\SOFTWARE\Wiley' | Out-Null
$Query2 = "SELECT * FROM RegistryValueChangeEvent 
            WHERE Hive='HKEY_LOCAL_MACHINE' 
              AND KeyPath='SOFTWARE\\Wiley' AND ValueName='MOLTUAE'"
$Action2 = { 
  Write-Host -Object "Registry Value Change Event Occurred"
  $Global:RegEvent = $Event }
Register-CimIndicationEvent -Query $Query2 -Action $Action2 -Source RegChange

# 7. Create a new registry key and change a value entry
$Q2HT = [ordered] @{
  Type  = 'DWord'
  Name  = 'MOLTUAE' 
  Path  = 'HKLM:\Software\Wiley' 
  Value = 42 
}
Set-ItemProperty @Q2HT
Get-ItemProperty -Path HKLM:\SOFTWARE\Wiley

# 8. Unregister for the event
Unregister-Event -SourceIdentifier 'RegChange'

# 9. Look at result details
$RegEvent.SourceEventArgs.NewEvent

# 10. Create WQL Event Query
$Group = 'Enterprise Admins'
$Query1 = @"
  Select * From __InstanceModificationEvent Within 5  
   Where TargetInstance ISA 'ds_group' AND 
         TargetInstance.ds_name = '$Group'
"@

# 11. Create a temporary WMI event indication
$Event = @{
  Namespace =  'root\directory\LDAP'
  SourceID  = 'DSGroupChange'
  Query     = $Query1
  Action    = {
    $Global:ADEvent = $Event
    Write-Host 'We have a group change'          }
}
Register-CimIndicationEvent @Event

# 12. Add a user to the enterprise admin group
Add-ADGroupMember -Identity 'Enterprise admins' -Members Sylvester

# 13. View who was added
$ADEvent.SourceEventArgs.NewEvent.TargetInstance | 
  Format-Table -Property DS_sAMAccountName*,DS_Member

# 14. Unregister for the event
Unregister-Event -SourceIdentifier 'DSGroupChange'



