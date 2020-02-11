# 7.2 - Publishing a printer
#
# Run on Psrv
# Uses Printer added in 7.1

# 1. Get the printer object
$Printer = Get-Printer -Name SalesPrinter1

# 2. Checking the initial publication status
$Printer | Format-Table -Property Name, Published

# 3. Publish and share the printer to AD
$Printer | Set-Printer -Location '10th floor 10E4'
$Printer | Set-Printer  -Published $true

# 4. View the updated publication status
Get-Printer -Name SalesPrinter1 |
  Format-Table -Property Name, Location, DriverName, Published, Shared
