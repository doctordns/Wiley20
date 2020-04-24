# 4.7 Configuring DNS Zones and Resource Records 

# Run on DC1 after building the domain

# 1. Create a new primary forward DNS zone for Cookham.Net
Import-Module DNSServer
$ZHT1 = @{
  Name              = 'Cookham.Net'
  ResponsiblePerson = 'dnsadmin.cookham.net.' 
  ReplicationScope  = 'Forest'
  ComputerName      = 'DC1.Reskit.Org'
}
Add-DnsServerPrimaryZone @ZHT1

# 2. Create a reverse lookup zone
$ZHT2 = @{
  NetworkID         = '10.10.10.0/24'
  ResponsiblePerson = 'dnsadmin.reskit.org.' 
  ReplicationScope  = 'Forest'
  ComputerName      = 'DC1.Reskit.Org'
}
Add-DnsServerPrimaryZone @ZHT2

# 3. Register DNS for DC1, DC2 
Register-DnsClient
Invoke-Command -ComputerName DC1 -ScriptBlock {Register-DnsClient}

# 4. Check The DNS zones ON DC1
Get-DNSServerZone -ComputerName DC1

# 5. Add Resource Record to Cookham.Net zone
# Add an A record
$RRHT1 = @{
  ZoneName      =  'Cookham.Net'
  A              =  $true
  Name           = 'Home'
  AllowUpdateAny =  $true
  IPv4Address    = '10.42.42.42'
  TimeToLive     = (30 * (24 * 60 * 60))  # 30 days in seconds
}
Add-DnsServerResourceRecord @RRHT1
# Add a Cname record
$RRHT2 = @{
  ZoneName      = 'Cookham.Net'
  Name          = 'MAIL'
  HostNameAlias = 'Home.Cookham.Net'
  TimeToLive     = (30 * (24 * 60 * 60))  # 30 days in seconds
}
Add-DnsServerResourceRecordCName @RRHT2
# Add an MX record
$MXHT = @{
  Preference     = 10 
  Name           = '.'
  TimeToLive     = '1:00:00'
  MailExchange   = 'Mail.Cookham.Net'
  ZoneName       = 'Cookham.Net'
}
Add-DnsServerResourceRecordMX @MXHT

# 6. Restart DNS Service to ensure replication
Restart-Service -Name DNS
$SB = {Restart-Service -Name dns}
Invoke-Command -ComputerName DC2 -ScriptBlock $SB

# 7. Check results of RRs in Cookham.Net zone
Get-DnsServerResourceRecord -ZoneName 'Cookham.Net'

# 8. Test DNS Resolution on DC2, DC1
# Test The Cname
Resolve-DnsName -Server DC1.Reskit.Org -Name 'Mail.Cookham.Net'
# Test The MX on DC2
Resolve-DnsName -Server DC2.Reskit.Org -Name 'Cookham.Net'  -Type MX 

