#  7.1 - Installing IIS
#
# Uses NLB1


# 1. Installing the WindowsCompatibility module
Install-Module -Name WindowsCompatibility  -Force

# 2. Installing Web Server feature
Import-Module -Name WindowsCompatibility
Import-WinModule -Name ServerManager
$FHT = @{
  Name                  = 'Web-Server'
  IncludeAllSubFeature   = $true
  IncludeManagementTools = $true
}
Install-WindowsFeature  @FHT

# 3. Viewing Web based features available on NLB1
$SB = {
  Get-WindowsFeature -Name Web*  | 
    Where-Object Installed|
      Format-Table
}
Invoke-Command -ComputerName NLB1 -ScriptBlock $SB

# 4. Checking the Management modules
$Modules = @('WebAdministration', 'IISAdministration')
Get-WinModule -Name $Modules


# 5. Get counts of commands in each module
Import-WinModule -name $Modules
$C1 = (Get-Command -Module WebAdministration |
        Measure-Object |
          Select-Object -Property Count).Count
$C2 = (Get-Command -Module IISAdministration |
        Measure-Object |
          Select-Object -Property Count).Count
"$C1 commands in WebAdministration Module"
"$C2 commands in IISAdministration Module"

# 5. Look at the IIS provider
Import-Module -Name WebAdministration
Get-PSProvider -PSProvider WebAdministration

# 6. What is in the IIS:
Get-ChildItem -Path IIS:\

# 7. What is in sites folder?
Get-Childitem -Path IIS:\Sites

# 8. Look at the default web site:
$IE  = New-Object -ComObject InterNetExplorer.Application
$URL = 'HTTP://NLB1'
$IE.Navigate2($URL)
$IE.Visible = $true
