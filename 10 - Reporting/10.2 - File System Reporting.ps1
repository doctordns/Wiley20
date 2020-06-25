# 10.2 - Using FSRM Reporting
#
# Run on SRV1 after you installing FSRM

# 1. Create a new Storage report for large files on C:\ on SRV1
$REPORT1HT = @{
  Name             = 'Large Files on SRV1'
  NameSpace        = 'C:\'
  ReportType       = 'Large'
  ReportFormat     = ('DHTML','XML')
  LargeFileMinimum = 10MB 
  Interactive      = $true 
  MailTo           = 'DoctorDNS@Gmail.Com'
  }
New-FsrmStorageReport @REPORT1HT

# 2. View FSRM Reports
Get-FsrmStorageReport * |
 Format-Table -Property Name, ReportType, ReportFormat, Status

# 3. Viewing Storage Report Output
$Path = 'C:\StorageReports\Interactive'
Get-ChildItem -Path $Path

# 4. View the DHTML report
$Rep = Get-ChildItem -Path $Path\*.html
Invoke-item -Path $Rep

# 5. Extract key information from the XML
$XF   = Get-ChildItem -Path $Path\*.xml 
$XML  = [XML] (Get-Content -Path $XF)
$Files = $XML.StorageReport.ReportData.Item
$Files | Where-Object Path -NotMatch '^Windows|^Program|^Users' |
  Format-Table -Property Name, Path,
               @{ Name ='Size MB'
                  Alignment = 'right'
                  Expression = {(([int]$_.size)/1mb).TosString('N2')}},
               DaysSinceLastAccessed -AutoSize

# 6. Create a monthly FSRM Task
$Date = Get-Date '04:20'
$NTHT = @{
  Time    = $Date
  Monthly = 1
}
$Task = New-FsrmScheduledTask @NTHT

# 7. Create a new FSRM monthly report
$ReportName = 'Monthly-Files By Owner'
$REPORT2HT = @{
  Name             = $ReportName
  Namespace        = 'C:\'
  Schedule         = $Task 
  ReportType       = 'FilesByOwner'
  MailTo           = 'DoctorDNS@Gmail.Com'
}
New-FsrmStorageReport @REPORT2HT | Out-Null

# 8. Get details of the scheduled task
Get-ScheduledTask | 
  Where-Object TaskName -match $ReportName |
    Format-Table -AutoSize

# 9. Run the task interactively
Get-ScheduledTask |
  Where-Object TaskName -match $ReportName |
    Start-ScheduledTask 
Get-ScheduledTask -TaskName '*Monthly*'

# 10. View the report
$Path = 'C:\StorageReports\Scheduled'
$Rep = Get-ChildItem -Path $path\*.html
Invoke-item -Path $Rep


# 11. Remove the objects 
#  Remove the scheduled task
Get-ScheduledTask | 
  Where-Object TaskName -match $ReportName | 
    Unregister-ScheduledTask -Confirm:$False
Remove-FsrmStorageReport $ReportName -Confirm:$False
Get-Childitem C:\StorageReports\Interactive,
              C:\StorageReports\Scheduled | 
  Remove-Item -Force -Recurse