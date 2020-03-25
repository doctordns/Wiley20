# 4.5 - Configuring DHCP Load Balancing and Failover

# Run on DC2 after setting DC1 up as a DHCP Server 
# And with and a Scope defined

# 1. Install the DHCP Server feature on DC2
Import-Module -Name ServerManager -WarningAction SilentlyContinue
$FEATUREHT = @{
  Name                   = 'DHCP'
  IncludeManagementTools = $True
}
Install-WindowsFeature @FEATUREHT

# 2. Let DHCP Know It Is Fully Configured
$IPHT = @{
  Path  = 'HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12'
  Name  = 'ConfigurationState'
  Value = 2
}
Set-ItemProperty @IPHT

# 3. Authorize the DHCP Server in AD
Import-Module -Name DHCPServer -WarningAction 'SilentlyContinue'
Add-DhcpServerInDC -DnsName DC2.Reskit.Org

# 4. View Authorized DHCP Servers
Get-DhcpServerInDC

# 5. Configure failover and load balancing:
$FAILOVERHT = @{
  ComputerName       = 'DC1.Reskit.Org'
  PartnerServer      = 'DC2.Reskit.Org'
  Name               = 'DC1-DC2'
  ScopeID            = '10.10.10.0'
  LoadBalancePercent = 60
  SharedSecret       = 'j3RryIsG0d!'
  Force              = $true
}
Invoke-Command -ComputerName DC1.reskit.org -ScriptBlock {
  Add-DhcpServerv4Failover @Using:FAILOVERHT  
}

# 6. Get active leases in the scope (from both servers!)
$DHCPServers = 'DC1.Reskit.Org', 'DC2.Reskit.Org' 
$DHCPServers |   
  ForEach-Object { 
    "Server $_" | Format-Table
    Get-DhcpServerv4Scope -ComputerName $_ | Format-Table
  }

# 7. View DHCP Server Statistics from both DHCP Servers
$DHCPServers |
  ForEach-Object {
    "Server $_" | Format-Table
    Get-DhcpServerv4ScopeStatistics -ComputerName $_  | Format-Table
  } 
