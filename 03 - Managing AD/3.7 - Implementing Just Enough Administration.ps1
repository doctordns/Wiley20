# Recipe 3.7 - Implementing JEA
# Run on DC1


# Relies on AD IT, and JerryG user create earlier

# 1. Create Capabilities  Folder
$JEACF = "C:\JEACapabilities"
New-Item -Path $JEACF -ItemType Directory | Out-Null

# 2. Create Role Capabilities file in the folder
$RCF = Join-Path -Path $JEACF -ChildPath "RKDnsAsmins.psrc"
$RCHT = @{
  Path            = $RCF
  Author          = 'Reskit Administration'
  CompanyName     = 'Reskit.Org' 
  Description     = 'Defines RKDnsAdmins role capabilities'
  AliasDefinition = @{name='gh';value='Get-Help'}
  ModulesToImport = 'Microsoft.PowerShell.Core','DnsServer'
  VisibleCmdlets  = ("Restart-Service",
                     @{ Name       = "Restart-Computer"; 
                        Parameters = @{Name = "ComputerName"}
                        ValidateSet = 'DC1, DC2'},
                      'DNSSERVER\*')
  VisibleExternalCommands = ('C:\Windows\System32\whoami.exe')
  VisibleFunctions = 'Get-HW'
  FunctionDefinitions = @{
    Name = 'Get-HW'
    Scriptblock = {'Hello JEA World'}}
}
New-PSRoleCapabilityFile @RCHT -verbose

# 3. Create a JEA Session Configuration file
$SCF = "C:\JEASessionConfiguration"
$P   = Join-Path -Path $SCF -ChildPath 'RKDnsAdmins.pssc'
$RDHT = @{
  'Reskit\RKDnsAdmins' = @{'RoleCapabilityFiles' = 'C:\JEACapabilities\RKDnsAsmins.psrc'
}
}
$PSCHT= @{
  Author              = 'DoctorDNS@Gmail.Com'
  Description         = 'Session Definition for RKDnsAdmins'
  SessionType         = 'RestrictedRemoteServer'   # ie JEA!
  Path                = $P       # Role Capabilties file
  RunAsVirtualAccount = $true
  TranscriptDirectory = 'C:\Foo\JeaTranscripts'
  RoleDefinitions     = $RDHT     # RKDnsAdmins role mapping
}
New-PSSessionConfigurationFile @PSCHT

# 4. Test the session configuration file
Test-PSSessionConfigurationFile -Path $P 

# 5. Enable Remoting and Register the JEA Session Definition
Enable-PSRemoting -Force 
  Out-Null
$SCHT = @{
  Path  = $P
  Name  = 'RKDnsAdmins' 
  Force =  $true 
}
Register-PSSessionConfiguration @SCHT

# 6. Check What the User Can Do
Get-PSSessionCapability -ConfigurationName RkDnsAdmins -Username 'Reskit\Jerryg' |
  Sort-Object Module

# 7. Create Credentials for user JerryG
$U    = 'JerryG@Reskit.Org'
$P    = ConvertTo-SecureString 'Pa$$w0rd' -AsPlainText -Force 
$Cred = New-Object System.Management.Automation.PSCredential $U,$P

# 8. Define Three Script Blocks and an Invocation Splatting Hast Table
$SB1   = {Get-Command}
$SB2   = {Get-HW}
$SB3   = {Get-Command -Name  '*-DNSSERVER*'}
$ICMHT = @{
  ComputerName      = 'DC1.Reskit.Org'
  Credential        = $Cred 
  ConfigurationName = 'RKDnsAdmins' 
} 

# 12. How many Commands are available within the JEA session
Invoke-Command -ScriptBlock $SB1 @ICMHT |
  Sort-Object -Property Module |
    Select-Object -First 15

# 13. Invoke a JEA Defined Function in a JEA Ssession As JerryG
Invoke-Command -ScriptBlock $SB2 @ICMHT

# 14. Get DNSServer commands available to JerryG
$C = Invoke-command -ScriptBlock $SB3 @ICMHT 
"$($C.Count) DNS commands available"

# 15 Examine the contents of the Transcripts folder:
Get-ChildItem -Path $PSCHT.TranscriptDirectory

# 16. Examine a transcript
Get-ChildItem -Path $PSCHT.TranscriptDirectory | 
  Select-Object -First 1  |
     Get-Content 



