# 4.3 - Instal and Authorize DC1 as a DHCP server
#
# Run on DC1 after AD setup (see Chapter 3, topic 1 for that)

# 1. Install the DHCP Feature on DC1 and add the Management tools
Import-Module -Name ServerManager -WarningAction SilentlyContinue
Install-WindowsFeature -Name DHCP -IncludeManagementTools

# 2. Add DC1 to Trusted DHCP Servers and add the DHCP Security Group
Import-Module -Name DHCPServer -WarningAction SilentlyContinue
Add-DhcpServerInDC
Add-DHCPServerSecurityGroup 

# 3. Let DHCP know it's all configured
$DHCPHT = @{
  Path  = 'HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12'
  Name  = 'ConfigurationState'
  Value = 2
}
Set-ItemProperty @DHCPHT

# 4. Restart DHCP Server 
Restart-Service -Name DHCPServer –Force 

# 5. Test service availability
Get-Service -Name DHCPServer | 
  Format-List -Property *