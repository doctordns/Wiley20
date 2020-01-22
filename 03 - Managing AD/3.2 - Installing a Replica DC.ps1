# Chapter 3 - Installing Replica Domain Controller

# Run on DC2 - a domain server
# DC1 is the forest root DC

# 1. Set CredSSP on DC2
Enable-WSManCredSSP -DelegateComputer *.Reskit.Org -Role Client -Force |
  Out-Null
Enable-WSManCredSSP -Role Server -Force  |
  Out-Null

# 2. Import the ServerManager Module
Import-Module -Name ServerManager -WarningAction SilentlyContinue

# 3. Check DC1 can be resolved, and can be reached from DC2
Resolve-DnsName -Name DC1.Reskit.Org -Type A
Test-NetConnection -ComputerName DC1.Reskit.Org -Port 445
Test-NetConnection -ComputerName DC1.Reskit.Org -Port 389

# 4. Add the AD DS features on DC2
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# 5. Create Script block to Promote DC2
$DC2SB= {
  Import-Module -Name ADDSDeployment 
  $URK    = "Administrator@Reskit.Org" 
  $PW     = 'Pa$$w0rd'
  $PSS    = ConvertTo-SecureString -String $PW -AsPlainText -Force
  $Class  = "System.Management.Automation.PSCredential"
  $CredRK = New-Object $Class -ArgumentList $URK,$PSS
  $INSTALLHT = @{
    DomainName                    = 'Reskit.Org'
    SafeModeAdministratorPassword = $PSS
    SiteName                      = 'Default-First-Site-Name'
    NoRebootOnCompletion          = $true
    InstallDNS                    = $false
    Credential                    = $CredRK
    Force                         = $true
  } 
  Install-ADDSDomainController @INSTALLHT
}

# 6. Create and View a PS Session on DC2
$URK    = "Administrator@Reskit.Org" 
$PW     = 'Pa$$w0rd'
$PSS    = ConvertTo-SecureString -String $PW -AsPlainText -Force
$Class  = "System.Management.Automation.PSCredential"
$CredRK = New-Object $Class -ArgumentList $URK,$PSS
$SESSIONHT = @{
  Name           = 'WinPSCompatSession2'
  ComputerName   = 'DC2.Reskit.Org'
  Credential     = $CredRK 
  Authentication = 'CredSSP'
}
$SESSION = New-PSSession @SESSIONHT
$SESSION

# 7. Invoke the Script Block Inside the Session
Invoke-Command -Session $SESSION -ScriptBlock $DC2SB

# 8. Reboot manually
Restart-Computer -Force

###  DC2 reboots at this point
### Relogon as Adminstrator@reskit.org

# 9. Check DCs in Reskit.Org
$SB = 'OU=Domain Controllers,DC=Reskit,DC=Org'
Get-ADComputer -Filter * -SearchBase $SB |
  Format-Table -Property DNSHostname, Enabled

# 10 Check Reskit.Org Domain
Get-ADDomain |
  Format-Table -Property Forest, Name, Replica*
