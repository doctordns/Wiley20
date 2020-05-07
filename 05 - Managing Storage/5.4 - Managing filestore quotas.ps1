# 5.4 - Managing filestore quotas
# 
# Run on SRV1, with SRV2, DC1 online


# 1. Install FS Resource Manager feature on SRV1
Import-module -Name ServerManager -WarningAction 'SilentlyContinue'
$IHT = @{
  Name                   = 'FS-Resource-Manager' 
  IncludeManagementTools = $True
  WarningAction          = 'SilentlyContinue'
}
Install-WindowsFeature @IHT

# 2. Set SMTP settings in FSRM
$MHT = @{
  SmtpServer        = 'SRV1.Reskit.Org'  
  FromEmailAddress  = 'FSRM@Reskit.Org'
  AdminEmailAddress = 'Doctordns@Gmail.Com'
}
Set-FsrmSetting @MHT

# 3. Send a test email to check the setup
$MHT = @{
  ToEmailAddress = 'DoctorDNS@gmail.com'
  Confirm        = $false
}
Send-FsrmTestEmail @MHT

# 4. Create a new FSRM quota template for a 10MB hard limit
$QHT1 = @{
  Name        = '10 MB Reskit Quota'
  Description = 'Filestore Quota (10mb) For'
  Size        = 10MB
}
New-FsrmQuotaTemplate @QHT1

# 5. View available FSRM quota templates
Get-FsrmQuotaTemplate |
  Format-Table -Property Name, Description, Size, SoftLimit
  
# 6. Create a new folder on which to place quotas
If (-Not (Test-Path C:\Quota)) {
  New-Item -Path C:\Quota -ItemType Directory  |
    Out-Null
}

# 7.  Build an FSRM Action
$Body = @'
User [Source Io Owner] has exceeded the [Quota Threshold]% quota 
threshold for the quota on [Quota Path] on server [Server].  
The quota limit is [Quota Limit MB] MB, and [Quota Used MB] MB 
currently is in use ([Quota Used Percent]% of limit).
'@
$NAHT = @{
  Type      = 'Email'
  MailTo    = 'Doctordns@gmail.Com'
  Subject   = 'FSRM Over limit [Source Io Owner]'
  Body      = $Body
}
$Action1 = New-FsrmAction @NAHT

# 8. Create an FSRM threshold 
$Thresh = New-FsrmQuotaThreshold -Percentage 85 -Action $Action1

# 9. Build a quota for the folder
$NQHT1 = @{
  Path      = 'C:\Quota'
  Template  = '10 MB Reskit Quota'
  Threshold = $Thresh
}
New-FsrmQuota @NQHT1

# 10. Test the 85% SOFT quota limit on C:\Quota
Get-ChildItem -Path C:\Quota -Recurse | 
  Remove-Item -Force     # for testing purposes!
$S = '+'.PadRight(8MB)
# Make a first file - under the soft quota
$S | Out-File -FilePath C:\Quota\Demo1.Txt
$S2 = '+'.PadRight(.66MB)
# Now create a second file to take the user over the soft quota
$S2 | Out-File -FilePath C:\Quota\Demo2.Txt


# 11. Test Hard limit quota
$S | Out-File -FilePath C:\Quota\demo3.Txt    

# 12. View Folder
Get-ChildItem -Path C:\Quota |
   Measure-Object -Sum -Property Length
