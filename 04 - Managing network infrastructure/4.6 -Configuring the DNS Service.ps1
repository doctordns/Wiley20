# 4.6 - Configuring the DNS Service

# Run this on DC2

# 1. Install the DNS Feature
Import-Module -Name ServerManager -WarningAction SilentlyContinue
Install-WindowsFeature -Name DNS -IncludeManagementTools  

# 2. Set Key DNS Server Options:
# Enable recursion on this server
Set-DnsServerRecursion -Enable $true
# Configure DNS Server cache maximum size
Set-DnsServerCache  -MaxKBSize 20480  # 28 MB
# Enable EDNS
$EDNSHT = @{
  EnableProbes    = $true
  EnableReception = $true
}
Set-DnsServerEDns @EDNSHT
# Enable Global Name Zone
Set-DnsServerGlobalNameZone -Enable $true

# 3. View DNS Service and note the module
# Get DNS Server Settings
$WAHT = @{WarningAction='SilentlyContinue'}
$DNSRV = Get-DNSServer -ComputerName DC2.Reskit.Org @WAHT
# View Recursion settinngs
$DNSRV |
  Select-Object -ExpandProperty ServerRecursion
# View Server Cache settings
$DNSRV | 
  Select-Object -ExpandProperty ServerCache
# View ENDS Settings
$DNSRV |
  Select-Object -ExpandProperty ServerEdns
