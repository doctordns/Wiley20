# 10.9 - Reviewing Event Logs
#
# Run on DC1


# 1. Count logs and logs with records:
$EventLogs  = Get-WinEvent -ListLog *
$Logs       = $EventLogs.Count
$ActiveLogs = ($Eventlogs | Where-Object RecordCount -gt 0).count
"On $(hostname) there are $Logs logs available"
"$ActiveLogs have records"

# 2. Get total event records available
$EntryCount = ($EventLogs | Measure-Object -Property RecordCount -Sum).Sum
"Total Event logs entries: [{0:N0}]" -f $EntryCount

# 3. Get count of events in System, Application and Security logs
$Syslog = Get-WinEvent -ListLog System
$Applog = Get-WinEvent -ListLog Application
$SecLog = Get-WinEvent -ListLog Security
"System Event log entries:      [{0,10:N0}]" -f $Syslog.RecordCount
"Application Event log entries: [{0,10:N0}]" -f $Applog.RecordCount
"Security Event log entries:    [{0,10:N0}]" -f $Seclog.RecordCount

# 4. Get all Windows Security Log events
$SecEvents = Get-WinEvent -LogName Security 
"Found $($SecEvents.count) security events"

# 5. Get Logon Events
$Logons = $SecEvents | Where-Object ID -eq 4624   # logon event
"Found $($Logons.count) logon events"

# 6. Create summary array of logon events
$MSGS = @()
Foreach ($Logon in $Logons) {
    $XMLMSG = [xml] $Logon.ToXml()
    $t = '#text'
    $HostName   = $XMLMSg.Event.EventData.data.$t[1]
    $HostDomain = $XMLMSg.Event.EventData.data.$t[2]
    $Account    = $XMLMSg.Event.EventData.data.$t[5]
    $AcctDomain = $XMLMSg.Event.EventData.data.$t[6]
    $LogonType  = $XMLMSg.Event.EventData.data.$t[8]
    $MSG = New-Object -Type PSCustomObject -Property @{
       Account   = "$AcctDomain\$Account"
       Host      = "$HostDomain\$Hostname"
       LogonType = $LogonType
       Time      = $Logon.TimeCreated
    }
    $MSGS += $MSG
}

# 7. Display results
$MSGS | 
  Group-Object -Property LogonType |
    Format-Table Name, Count

# 8. Examine RDP logons
$MSGS | Where-Object logontype -eq '10'



