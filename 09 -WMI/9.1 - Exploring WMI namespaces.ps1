# 9.1 Exploring WMI namespaces
#
# Run on DC1


# 1. View CIM classes in the root namespace
Get-CimClass -Namespace 'root' | Select-Object -First 20

# 2. Look in __NAMESPACE in Root
Get-CimInstance -Namespace 'root' -ClassName __NAMESPACE |
  Sort-Object -Property Name

# 3. Get and count classes in root\CimV2
$Classes = Get-CimClass -Namespace 'root\CimV2'  
"There are $($Classes.Count) classes in root\CimV2"

# 4. Discovering ALL namespaces on DC1
Function Get-WMINamespaceEnum {
  [CmdletBinding()]
  Param($NS) 
  Write-Output $NS
  Get-CimInstance "__Namespace" -Namespace $NS -ErrorAction SilentlyContinue | 
  ForEach-Object { Get-WMINamespaceEnum "$ns\$($_.name)"   }
}  # End of function
$Namespaces = Get-WMINamespaceEnum 'root' | Sort-Object
"There are $($Namespaces.count) WMI namespaces on this host"

# 5. View some of the namespaces on DC1
$Namespaces |
  Select-Object -First 20

# 6. Counting WMI classes on DC1
$WMICLasses = @()
Foreach ($Namespace in $Namespaces) {
  $WMICLasses += Get-CimClass -Namespace $Namespace
}
"There are $($WMIClasses.count) classes on $(hostname)"

# 7. View namespaces on SRV2
Get-CimInstance -Namespace root -ClassName __NAMESPACE -CimSession SRV2

# 8. Enumerate all namespaces and Classes on SRV2
$SB = {
 Function Get-WMINamespaceEnum {
   [CmdletBinding()]
   Param(
     $NS
    ) 
   Write-Output $NS
   Get-CimInstance "__Namespace" -Namespace $NS -ErrorAction SilentlyContinue | 
     ForEach-Object { Get-WMINamespaceEnum "$ns\$($_.name)"   }
   }  # End of function
   $Namespaces = Get-WMINamespaceEnum 'root' | Sort-Object
   $WMICLasses = @()
   Foreach ($Namespace in $Namespaces) {
   $WMICLasses += Get-CimClass -Namespace $Namespace
  }
 "There are $($Namespaces.count) WMI namespaces on $(hostname)"
 "There are $($Wmiclasses.count) classes on $(hostname)"
}
Invoke-Command -ComputerName SRV2 -ScriptBlock $SB

# 9. Run the script block on DC2
Invoke-Command -ComputerName DC2 -ScriptBlock $SB

