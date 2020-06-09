# 9.4 - Invoking WMI methods

# Run on DC1

# 1. Review methods of Win32_Share class
Get-CimClass -ClassName Win32_Share | 
  Select-Object -ExpandProperty CimClassMethods

# 2. Review properties of Win32_Share class
Get-CimClass -ClassName Win32_Share | 
  Select-Object -ExpandProperty CimClassProperties |
    Format-Table -Property Name, CimType

# 3. Create Hash Table of new share properties using static method
$NSHT = @{
  Name        = 'TestShare1'
  Path        = 'C:\Foo'
  Description = 'Test Share'
  Type        = [uint32] 0 # disk
}    
Invoke-CimMethod -ClassName Win32_Share -MethodName Create -Arguments $NSHT

# 4. View the new SMB Share
Get-SMBShare -Name 'TestShare1'

# 5. View the new SMB Share using Get-CimInstance
Get-CimInstance -Class Win32_Share -Filter "Name = 'TestShare1'"

# 6. Remove the share
Get-CimInstance -Class Win32_Share -Filter "Name = 'TestShare1'" |
  Invoke-CimMethod -MethodName Delete

