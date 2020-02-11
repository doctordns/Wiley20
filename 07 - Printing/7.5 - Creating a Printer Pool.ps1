# 7.5 - Create Printer Pool
# Run on PSRV printer server

# 1. Add a port for the printer 
$P = 'SalesPrinter1'   # printer name
$PP2 = 'SalesPP2'   # new printer port name
Add-PrinterPort -Name $PP2 -PrinterHostAddress 10.10.10.62 

# 2. Creating the printer pool for SalesPrinter1
$PP1='SalesPP'   # first port name
rundll32.exe printui.dll,PrintUIEntry /Xs /n $P Portname $PP1,$PP2

# 3. View resultant details:
Get-Printer $P | 
   Format-Table -Property Name, Type, DriverName, PortName,
                          Shared, Published
