# Chapter 3 - Topic 3 - Installing a Child Domain

# Run on UKDC1 - a workgroup computer
# DC1.Reskit.Org is the forest root DC

# 1. Set CredSSP on UKDC1
Enable-WSManCredSSP -DelegateComputer *.Reskit.Org -Role Client -Force |
  Out-Null
Enable-WSManCredSSP -Role Server -Force  |
  Out-Null

# 2. Import the ServerManager module
Import-Module -Name ServerManager -WarningAction SilentlyContinue

# 3. Check DC1 can be resolved and  can be reached over 445 and 389 from DC2
Resolve-DnsName -Name DC1.Reskit.Org -Type A
Test-NetConnection -ComputerName DC1.Reskit.Org -Port 445
Test-NetConnection -ComputerName DC1.Reskit.Org -Port 389

# 4. Add the AD DS features on UKDC1
$Features = 'AD-Domain-Services'
Install-WindowsFeature -Name $Features -IncludeManagementTools

# 5. Create Script Block to Create New Domain
$UKDSB= {
  Import-Module -Name ADDSDeployment 
  $URK    = "Administrator@Reskit.Org" 
  $PW     = 'Pa$$w0rd'
  $PSS    = ConvertTo-SecureString -String $PW -AsPlainText -Force
  $Class  = "System.Management.Automation.PSCredential"
  $CredRK = New-Object -Typename $Class -ArgumentList $URK,$PSS
  $INSTALLHT    = @{
    NewDomainName                 = 'UK'
    ParentDomainName              = 'Reskit.Org'
    DomainType                    = 'ChildDomain'
    SafeModeAdministratorPassword = $PSS
    ReplicationSourceDC           = 'DC1.Reskit.Org'
    Credential                    = $CredRK
    SiteName                      = 'Default-First-Site-Name'
    InstallDNS                    = $false
    Force                         = $true
  }
  Install-ADDSDomain @INSTALLHT
}

# 6. Create and View a PS Session on UKDC1
$URK      = "Administrator@Reskit.Org" 
$PW       = 'Pa$$w0rd'
$PSS      = ConvertTo-SecureString -String $PW -AsPlainText -Force
$Class    = "System.Management.Automation.PSCredential"
$CredRK = New-Object $Class -ArgumentList $URK,$PSS
$SESSIONHT = @{
  Name           = 'WinPSCompatSession2'
  ComputerName   = 'UKDC1'
  Authentication = 'CredSSP'
}
$SESSION = New-PSSession @SESSIONHT
$SESSION

# 7. Create The Child Domain
Invoke-Command -Session $SESSION -ScriptBlock $UKDSB
  
# 8. Look at AD forest
Get-ADForest -Server UKDC1.UK.Reskit.Org

# 9. Look at AD forest
Get-ADDomain -Server UKDC1.UK.Reskit.Org
