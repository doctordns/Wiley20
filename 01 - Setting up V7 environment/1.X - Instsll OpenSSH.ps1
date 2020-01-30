#  install ssh for powershell

# 1. Install the feature (if WIn 10
Get-WindowsCapability -Online | 
  Where-Object Name -like 'OpenSSH*'
    Add-WindowsCapability -Online
    
# 2. Start SSHD service (to reveive ssh inbound)    
Set-Service -Name sshd -StartupType 'Automatic'
Start-Service -Name sshd

# 3. Create host filewall rule
$FWRHT = @{
  Action       = 'Allow'
  Name         = 'sshd'
  DisplayName  = 'OpenSSH Server (sshd)' 
  Enabled      = 'True'
  Direction    = 'Inbound'
  Protocol     = 'TCP'
   LocalPort    = 22
}
New-NetFirewallRule @FWRHT

# 4. Coinfigure inbound SSH to see PowerShell not CM
$RHT = @{
  Path         = 'HKLM:\SOFTWARE\OpenSSH'
  Name         = 'DefaultShell'
  Value        = "$PSHome\PWSH.Exe" 
  PropertyType = 'String'
  Force        = $true
}
New-ItemProperty @RHT

