# 4.7 Configuring DNS Zones and Resource Records 

# Run on DC1 after building the domain

# 1. Create a new primary forward DNS zone for Cookham.Net
Import-Module DNSServer
$ZHT = @{
  Name              = 'Cookham.Net'
  ZoneFile          = 'Cookham.Net.dns'
  ResponsiblePerson = 'dnsadmin.cookham.net.' 
  ComputerName      = 'DC1.Reskit.Org'
}
Add-DnsServerPrimaryZone @ZHT


# 2. Check The DNS Zones ON DC1
Get-DNSServerZone -ComputerName DC1

# 3. Add Resource Record to Kapoho.Com and get results:
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

# 4. Check results of RRs in Cookham.Net zone
$Zname = 'Cookham.Net'
Get-DnsServerResourceRecord -ZoneName $Zname


# 5. Test DNS Resolution on DC1
# Test The Cname
Resolve-DnsName -Server DC1.Reskit.Org -Name Mail.Cookham.Net
# Test The MX
Resolve-DnsName -Server DC1.Reskit.Org -Name 'Cookham.Net'  -Type MX 

