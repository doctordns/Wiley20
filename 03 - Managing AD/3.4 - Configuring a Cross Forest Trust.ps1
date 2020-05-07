# 3.4 - Adding a cross Forest Trust

# Uses KapDC1 (a workgroup server with nothing else but powershell loaded)

# 1. Import the ServerManager module on KAPDC1
Import-Module ServerManager -WarningAction SilentlyContinue

# 2. Install the AD Domain Services feature and Management Tools
$Features = 'AD-Domain-Services'
Install-WindowsFeature -Name $Features -IncludeManagementTools 

# 3. Test Network Connectivity with DC1
Test-NetConnection -ComputerName DC1

# 4. Import the AD DS Deployment Module
Import-Module -Name ADDSDeployment -WarningAction SilentlyContinue

# 5. Promote KAPDC1 to be DC in its own forest
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
}
Install-ADDSForest @ADINSTALLHT | Out-Null

# 6. View Kapoho.Com forest details
Get-ADForest

# 7. Adjust DNS on KAPDC1 to resolve Reskit.Org from DC1
$CFHT = @{
   Name          = 'Reskit.Org'
   MasterServers = '10.10.10.10' 
   Passthru      = $True
}
Add-DnsServerConditionalForwarderZone @CFHT

# 8. Test Conditional Forwarding
Resolve-DNSName -Name DC1.Reskit.Org -Type A

# 9. Create a Script Block to Add Conditional Forwarder on DC1
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

# 10. Create Credentials to Run A Command on DC1
$URK   = 'Reskit\Administrator'
$PRK   = ConvertTo-SecureString 'Pa$$w0rd' -AsPlainText -Force
$CREDRK =  [PSCredential]::New($URK,$PRK)

# 11. Set WinRM
$PATH = 'WSMan:\localhost\Client\TrustedHosts'
Set-Item -Path $PATH -Value '*.Reskit.Org' -Force

# 12. Run the Script Block On DC1
$NZHT = @{
  Computername = 'DC1.Reskit.Org'
  Script       = $SB
  Credential  = $CREDRK
}
Invoke-Command @NZHT 

# 13. Get Reskit.Org and Kapoho.Com details
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

# 14. View Reskit Forest Details 
$ReskitForest

# 15. Viewing Kapoho Forest Details
$KapohoForest

# 16. Establish a Cross Forest Trust
$KapohoForest.CreateTrustRelationship($ReskitForest,"Bidirectional")

# 17. Create SB to Adjust ACL on DC1
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

# 18. Run the Script Block on DC1 To Demonstrate X-Forest Trust
$PHT = @{
  ComputerName = 'DC1.Reskit.Org'
  Credential   = $CREDRK
  ScriptBlock  = $SB2
}
Invoke-Command  @PHT
