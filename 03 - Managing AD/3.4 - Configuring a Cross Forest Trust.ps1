# 3.4 - Adding a cross Forest Trust

# Uses KapDC1 (a workgroup server with nothing else but powershell loaded)

# 1. Set CredSSP on UKDC1
Enable-WSManCredSSP -DelegateComputer *.Reskit.Org -Role Client -Force |
  Out-Null
Enable-WSManCredSSP -Role Server -Force  |
  Out-Null

# 2. Import the ServerManager module on KAPDC1
$EWA = @{WarningAction = 'SilentlyContinue'}
Import-Module ServerManager @EWA

# 3. Install the AD Domain Services Feature and Management toolsT
$FEATUREHT = @{
  Name                   = 'AD-Domain-Services'
  IncludeManagementTools = $True
  WarningAction          = 'SilentlyContinue'
}
Install-WindowsFeature @FEATUREHT

# 4. Test Network Connectivity with DC1
Test-NetConnection -ComputerName DC1

# 5. Import the AD DS Deployment Module
Import-Module -Name ADDSDeployment @EWA


# 6. Promote KAPDC1 to be DC in it's Own Forest
$ADINSTALLHT = @{
  String      = 'Pa$$w0rd'
  AsPlainText = $True
  Force       = $True
}
$SECUREPW = ConvertTo-SecureString @ADINSTALLHT
$ADINSTALLHT = @{
  DomainName                    = 'Kapoho.Com' # Forest Root
  SafeModeAdministratorPassword = $SecurePW
  InstallDNS                    = $True
  DomainMode                    = 'WinThreshold' # latest
  ForestMode                    = 'WinThreshold' # Latest
  Force                         = $True
  WarningAction                 = 'SilentlyContinue'
  NoRebootOnCompletion          = $True
}
Install-ADDSForest @ADINSTALLHT | Out-Null


# 7. Restart to Complete Creation of Forest/Domain
Restart-Computer -Force

# 8. View Kapoho.Com Forest Details
Get-ADForest

# 9. Adjust DNS on KAPDC1 to resolve Reskit.Org from DC1
$CFHT = @{
   Name          = 'Reskit.Org'
   MasterServers = '10.10.10.10' 
   Passthru      = $True
}
Add-DnsServerConditionalForwarderZone @CFHT

# 10. Test Conditional Forwarding
Resolve-DNSName -Name DC1.Reskit.Org -Type A

# 11. Create a Script Block to Add Conditional Forwarder on DC1
$SB = {
  # Add CF zone
  $CFHT = @{
    Name          = 'Kapoho.Com'
    MasterServers = '10.10.10.131' 
   }
  Add-DnsServerConditionalForwarderZone @CFHT
  # Test it
  Resolve-DNSName -Name KAPDC1.Kapoho.Com | Format-Table
}  

# 12. Create Credentials to Run A Command on DC1
$URK   = 'Reskit\Administrator'
$PRK   = ConvertTo-SecureString 'Pa$$w0rd' -AsPlainText -Force
$CREDRK = New-Object System.Management.Automation.PSCredential $URK, $PRK

# 13. Set WinRM for NOW
$PATH = 'WSMan:\localhost\Client\TrustedHosts'
Set-Item -Path $PATH -Value '*.Reskit.Org' -Force

# 14. Run the Script Block On DC1
$NZHT = @{
  Computername = 'DC1.Reskit.Org'
  Script       = $SB
  Credential  = $CREDRK
}
Invoke-Command @NZHT 

# 15. Get Reskit.Org and Kapoho.Com details
$Reskit       = 'Reskit.Org'
$User         = 'Administrator'
$UserPW       = 'Pa$$w0rd'
$Type         = 'System.DirectoryServices.' +
                'ActiveDirectory.DirectoryContext'
$RKFHT = @{
  TypeName     = $Type
  ArgumentList = 'Forest',$Reskit,$User,$UserPW
}                
$RKF          = New-Object @RKFHT
$ReskitForest = 
  [System.DirectoryServices.ActiveDirectory.Forest]::GetForest($RKF)
$KapohoForest = 
  [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()

# 16. View Reskit Forest Details 
$ReskitForest

# 17. Viewing Kapoho Forest Details
$KapohoForest

# 18. Establish a Cross Forest Trust
$KapohoForest.CreateTrustRelationship($ReskitForest,"Bidirectional")

# 19. Create SB to Adjust ACL on DC1
$SB2 = {
  # Ensure NTFSSecurity module is loaded on DC1
  Install-Module -Name NTFSSecurity -Force -ErrorAction SilentlyContinue
  # Create a file in C:\Foo
  'XFT Test' | Out-File -FilePath 'C:\Foo\XFTTEST.Txt'
  # Test ACL
  Get-NTFSaccess -Path C:\Foo\XFTTEST.Txt | Format-Table
  # Add Kapoho\Administrators into ACL for this file
  $NTHT = @{
    Path         = 'C:\Foo\XFTTEST.TXT'
    Account      = 'Administrator@Kapoho.Com'
    AccessRights = 'FullControl'
  }
  Add-NTFSAccess @NTHT
  # Retest ACL
  Get-NTFSaccess -Path C:\Foo\XFTTEST.Txt | Format-Table
}

# 20. Run the Script Block on DC1 To Demonstrate X-Forest Trust
$PHT = @{
  ComputerName = 'DC1.Reskit.Org'
  Credential   = $CREDRK
  ScriptBlock  = $SB2
}
Invoke-Command  @PHT
