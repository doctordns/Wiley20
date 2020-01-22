# 4.5 - Managing filestore screening
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

# 5. Test Files screen by copying Notepad,exe
Copy-Item C:\Windows\notepad.exe C:\FileScreen\notepad.exe


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
New-FsrmFileScreen @FSFS 

# 7. re-test the file screen
Copy-Item C:\Windows\notepad.exe C:\FileScreen\notepad.exe

# 8. View File Screen Email

View from Outlook
