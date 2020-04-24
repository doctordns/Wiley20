# 9.3 - Getting Local and Remote Objects
# 
# run on DC1

# 1. Using Get-CimInstance in default Namespace
Get-CimInstance -ClassName Win32_Share

# 2. Get WMI objects from non-defaultnamespace
$GCIMHT1 = @{
    Namespace = 'root\directory\LDAP'
    ClassName = 'ds_group'
}
Get-Ciminstance @GCIMHT1|
  Sort-Object -Property Name |
    Select-Object -First 10 |
      Format-Table -Property DS_name, DS_distinguishedName

# 3. Using -Filter
$Filter = "ds_Name LIKE '%operator%' "
Get-Ciminstance @GCIMHT1  -Filter $Filter |
  Format-Table -Property ds_Name

# 4. Use a WMI Query
$Q = @"
  SELECT * from ds_group
    WHERE ds_Name like '%operator%'
"@
Get-CimInstance -Query $q -Namespace 'root\directory\LDAP' |
  Format-Table ds_Name

# 5. Get WMI Object from a remote system
Get-CimInstance -CimSession SRV2 -ClassName Win32_ComputerSystem 



