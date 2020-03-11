# Chapter 3 - Installing Replica Domain Controller

# Run on DC2 - a domain server
# DC1 is the forest root DC

# 1. Import the Server Manager Module
Import-Module -Name ServerManager -WarningAction SilentlyContinue

# 2. Check DC1 can be resolved and can be reached from DC2
Resolve-DnsName -Name DC1.Reskit.Org -Type A
Test-NetConnection -ComputerName DC1.Reskit.Org -Port 445
Test-NetConnection -ComputerName DC1.Reskit.Org -Port 389

# 3. Add the AD DS features on DC2
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# 4. Promote DC2
Import-Module -Name ADDSDeployment -WarningAction SilentlyContinue
$URK    = "Administrator@Reskit.Org" 
$PW     = 'Pa$$w0rd'
$PSS    = ConvertTo-SecureString -String $PW -AsPlainText -Force
$CredRK = [PSCredential]::New($URK,$PSS)
$INSTALLHT = @{
  DomainName                    = 'Reskit.Org'
  SafeModeAdministratorPassword = $PSS
  SiteName                      = 'Default-First-Site-Name'
  NoRebootOnCompletion          = $true
  InstallDNS                    = $false
  Credential                    = $CredRK
  Force                         = $true
  } 
Install-ADDSDomainController @INSTALLHT | Out-Null

# 5. Reboot manually
Restart-Computer -Force

###  DC2 reboots at this point
### Relogon as Adminstrator@reskit.org

# 6. Check DCs in Reskit.Org
$SB = 'OU=Domain Controllers,DC=Reskit,DC=Org'
Get-ADComputer -Filter * -SearchBase $SB |
  Format-Table -Property DNSHostname, Enabled

# 7. View Reskit.Org Domain
Get-ADDomain |
  Format-Table -Property Forest, Name, Replica*
