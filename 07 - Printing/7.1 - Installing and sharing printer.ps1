#  7.1 Installing and sharing printers
#  
#  Run on the PSRV server

# 1. Install the Print-Server feature on PSRV plus tools
Import-Module -Name ServerManager -WarningAction SilentlyContinue
Install-WindowsFeature -Name Print-Server -IncludeManagementTools

# 2. Creating a folder for the Xerox printer drivers
$NIHT = @{
  Path        = 'C:\Xerox'
  ItemType    = 'Directory'
  Force       = $true
  ErrorAction = 'Silentlycontinue'
}
New-Item @NIHT | Out-Null

# 3. Downloading printer drivers for Xerox printers
$URL    = 'http://bit.ly/XDrivers'
$Target = 'C:\Xerox\XDrivers.zip'
Start-BitsTransfer -Source $URL -Destination $Target

# 4. Expand the zip file
$Drivers = 'C:\Xerox\Drivers'
New-Item -Path $Drivers -ItemType Directory | Out-Null
Expand-Archive -Path $Target -DestinationPath $Drivers

# 5. Installing the drivers
$M1 = 'Xerox Phaser 6510 PCL6'
$P  = 'C:\Xerox\Drivers\6510_5.617.7.0_PCL6_x64_Driver.inf\x3NSURX.inf'
rundll32.exe printui.dll,PrintUIEntry /ia /m "$M1"  /f "$P"
$M2 = 'Xerox WorkCentre 6515 PCL6'
rundll32.exe printui.dll,PrintUIEntry /ia /m "$M2"  /f "$P"

# 6. Adding a new printer port
$PPHT = @{
  Name               = 'SalesPP' 
  PrinterHostAddress = '10.10.10.61'
}
Add-PrinterPort @PPHT  

# 7. Add a new printer
$PRHT = @{
  Name       = 'SalesPrinter1'
  DriverName = $M1 
  PortName   = 'SalesPP'
}
Add-Printer @PRHT

# 8. Share the printer
Set-Printer -Name SalesPrinter1 -Shared $True

# 9. Review pPrinter configuration
Get-PrinterPort -Name SalesPP |
  Format-Table -Autosize -Property Name, Description,
                       PrinterHostAddress, PortNumber
Get-PrinterDriver -Name xerox* |
  Format-Table -Property Name, Manufacturer,
                       DriverVersion, PrinterEnvironment
Get-Printer -ComputerName PSRV -Name SalesPrinter1 |
  Format-Table -Property Name, ComputerName,
                           Type, PortName, Location, Shared


