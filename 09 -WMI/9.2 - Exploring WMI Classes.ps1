# 9.1 Exploring WMI namespaces
#
# Run on DC1


# 1. View Win32_Share class
Get-CimClass -ClassName Win32_Share

# 2. Get Win32_Share class properties
Get-CimClass -ClassName Win32_Share |
  Select-Object -ExpandProperty CimClassProperties |
    Sort-Object -Property Name |
      Format-Table -Property Name, CimType

# 3. Get class methods
Get-CimClass -ClassName Win32_Share |
  Select-Object -ExpandProperty CimClassMethods

# 4. Get classes in a non-default namespace
Get-CimClass -Namespace root\directory\LDAP |
  Where-Object CimClassName -match '^ds_group'

