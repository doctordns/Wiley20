#  7.3 - Changing the spool directory

# Run on PSRV


# 1. Load the System.Printing namespace and classes
Add-Type -AssemblyName System.Printing

# 2. Displaying the initial spool folder
New-Object -TypeName System.Printing.PrintServer |
  Format-Table -Property Name,  DefaultSpoolDirectory

# 3. Define the required permissions—that is, the ability to 
#    administrate the server
$Permissions =
   [System.Printing.PrintSystemDesiredAccess]::AdministrateServer

# 4. Create a PrintServer object with the required permissions
$NOHT = @{
  TypeName     = 'System.Printing.PrintServer'
  ArgumentList = $Permissions
}
$PS = New-Object @NOHT     # Print Server object (as admin)

# 5. Create a new spool folder
$SP = 'C:\SpoolPath'
$NIHT = @{
  Path        = $SP
  ItemType    = 'Directory'
  Force       = $true
  ErrorAction = 'SilentlyContinue'
}
New-Item @NIHT | Out-Null 

# 6. Changing the spool folder path
$PS.DefaultSpoolDirectory = $SP

# 7. Committing the change:
$PS.Commit()

# 8. Restart the Spooler to use the new folder
Restart-Service -Name Spooler

# 9. Reviewing the spooler folder
New-Object -TypeName System.Printing.PrintServer |
    Format-Table -Property Name, DefaultSpoolDirectory



#  Another way to set the Spooler directory is by directly editing the registry as follows:


# 10. Create a new/different spool folder
$SPL = 'C:\SpoolViaRegistry'  # different spool folder
$NIHT2 = @{
  Path        = $SPL 
  Itemtype    = 'Directory'
  ErrorAction = 'SilentlyContinue'
}
New-Item  @NIHT2 | Out-Null

# 11. Stopping the Spooler service
Stop-Service -Name Spooler

# 12. Configure the new spooler folder
$RPath    = 'HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers'
$IP = @{
  Path    = $RPath
  Name    = 'DefaultSpoolDirectory'
  Value   = $SPL
}
Set-ItemProperty @IP

# 13. Restarting the Spooler
Start-Service -Name Spooler

# 14. View the results
New-Object -TypeName System.Printing.PrintServer |
 Format-Table -Property Name, DefaultSpoolDirectory