# 4.4 Configuring a DHCP Scope and DHCP Options

# Run on DC1, after DHCP Server service added

# 1. Create a IPV4 Scope
Import-Module DHCPServer -WarningAction SilentlyContinue
$SCOPEHT = @{
  Name         = 'ReskitOrg'
  StartRange   = '10.10.10.150'
  EndRange     = '10.10.10.199'
  SubnetMask   = '255.255.255.0'
  ComputerName = 'DC1.Reskit.Org'
}
Add-DhcpServerV4Scope @SCOPEHT

# 2. Get Scopes from the server
Get-DhcpServerv4Scope -ComputerName DC1.Reskit.Org

# 3. Set Server Wide Option Values
$OPTION1HT = @{
  ComputerName = 'DC1.Reskit.Org' # DHCP Server to Configure
  DnsDomain    = 'Reskit.Org'     # Client DNS Domain
  DnsServer    = '10.10.10.10'    # Client DNS Server
}
Set-DhcpServerV4OptionValue @OPTION1HT 

# 4. Set a scope specific option
$OPTION2HT = @{
  ComputerName = 'DC1.Reskit.Org' # DHCP Server to Configure
  Router       = '10.10.10.254'
  ScopeID      = '10.10.10.0'
}
Set-DhcpServerV4OptionValue @OPTION2HT 

# 5. Test the DHCP Sercice
#    Run on SRV2
$NICHT = @{
  InterfaceAlias = 'Ethernet'
  AddressFamily  = 'IPv4'
}
$NIC = Get-NetIPInterface @NICHT
Set-NetIPInterface -InterfaceAlias $nic.ifAlias -DHCP Enabled
Get-NetIPConfiguration
Resolve-DnsName -Name SRV2.Reskit.Org -Type A


