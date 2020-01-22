# 4.1 - Configuring an IP address

# Run this code on SRV2 directly

# 1. Get the adapter, adapter Interface and Adapter Interfaace Index
#   for later use
$IPType  = 'IPv4'
$Adapter = Get-NetAdapter |
  Where-Object Status -eq 'Up'     
$Interface = $Adapter |
  Get-NetIPInterface -AddressFamily $IPType
$Index = $Interface.IfIndex
Get-NetIPAddress -InterfaceIndex $Index -AddressFamily $IPType |
  Format-Table -Property Interface*, IPAddress, PrefixLength

# 2. Set a new IP address for the NIC
$IPHT = @{
  InterfaceIndex = $Index
  PrefixLength   = 24
  IPAddress      = '10.10.10.51'
  DefaultGateway = '10.10.10.254'
  AddressFamily  = $IPType
}
New-NetIPAddress @IPHT | Out-Null

# 3 Verify the new IP Address
Get-NetIPAddress -InterfaceIndex $Index -AddressFamily $IPType |
  Format-Table IPAddress, InterfaceIndex, PrefixLength

# 4. Set DNS Server IP address
$CAHT = @{
  InterfaceIndex  = $Index
  ServerAddresses = '10.10.10.10'
}
Set-DnsClientServerAddress @CAHT

# 5 Verify the New IP Configuration
# Verify the IPv4 address is set as required
Get-NetIPAddress -InterfaceIndex $Index -AddressFamily $IPType |
  Format-Table
# Test that SRV2 can see the domain controller
Test-NetConnection -ComputerName DC1.Reskit.Org |
  Format-Table
# Test the DNS server on DC1.Reskit.Org correctly resolves 
# the A record for SRV2.
Resolve-DnsName -Name SRV2.Reskit.Org -Server DC1.Reskit.Org -Type 'A'
  