# 5.5 - Managing Filestore Screening
# 
# Run on SRV1 with FSRM loaded


# 1. Examine the existing File groups
Get-FsrmFileGroup |
  Format-Table -Property Name, IncludePattern

# 2. Examine existing File Screen templates
Get-FsrmFileScreenTemplate |
  Format-Table -Property Name, IncludeGroup, Active

# 3. Create a new folder
$Path = 'C:\FileScreen'
If (-Not (Test-Path $Path)) {
  New-Item -Path $Path -ItemType Directory  |
    Out-Null
}

# 4. Create a new file screen
$FSHT =  @{
  Path         = $Path
  Description  = 'Block Executable Files'
  IncludeGroup = 'Executable Files'
}
New-FsrmFileScreen @FSHT

# 5. Test file screen by copying notepad.exe
$FSTHT = @{
  Path        = "$Env:windir\notepad.exe"
  Destination = 'C:\FileScreen\notepad.exe'
}
Copy-Item  @FSTHT

# 6. Setup Active Email Notification
$Body = "You attempted to save an executable program. This is not allowed."
$FSRMA = @{
  Type             = 'Email'
  MailTo           = "[Admin Email];[File Owner]" 
  Subject          = "Warning: attempted to save an executable file" 
  Body             = $Body
  RunLImitInterval = 60
}
$Notification = New-FsrmAction @FSRMA
$FSFS = @{
  Path         = $Path
  Notification = $Notification
  IncludeGroup = 'Executable Files'
  Description  = 'Block any executable file'
  Active       = $true
}
Set-FsrmFileScreen @FSFS 

# 7. Get-FSRM Notification Limits
Get-FsrmSetting | 
  Format-List -Property "*NotificationLimit"

# 8. ChangeignFSRM notification limits  
$FSRMSHT = @{
  CommandNotificationLimit = 1
  EmailNotificationLimit   = 1
  EventNotificationLimit   = 1
  ReportNotificationLimit  = 1
}
Set-FsrmSetting @FSRMSHt


# 9. Re-test the file screen to check the the action
Copy-Item @FSTHT

# 10. View File Screen Email
Get-FsrmSetting | WHERE-Object NAME -MATCH 'NotificationLimit'
# 
View from Outlook
