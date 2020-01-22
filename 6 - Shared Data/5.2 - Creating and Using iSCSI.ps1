# 5.4 - Creating/Using an iSCSI Target
# Uses FS1. FS2, and SRV2
# Starts on VMhost, then SRV2, and finished on FS1


# 0. Add additional disk to hold iSCSI VHD to SRV2 VM
#    Run this on the Hyper-V VM Host in an elevated console
# Stop the VM
Stop-VM -VMName SRV2
# Get File location for the disk in this VM
$VM = Get-VM -VMName SRV2
$Par = Split-Path -Path $VM.HardDrives[0].Path
# Create a new VHD for S drive
$NewPath3 = Join-Path -Path $par -ChildPath SDrive.VHDX
$D4 = New-VHD -Path $NewPath3 -SizeBytes 128GB -Dynamic
# Work out next free slot on Controller 0
$Free = Get-VMScsiController -VMName SRV2 | 
  Select-Object -ExpandProperty Drives |
    Measure-Object |
      Select-Object -ExpandProperty Count
# Add new disk to VM
$HDHT = @{ 
  Path               = $NewPath3
  VMName             = 'SRV2'
  ControllerType     = 'SCSI'
  ControllerNumber   = 0
  ControllerLocation = $Free
}
Add-VMHardDiskDrive @HDHT
# Start the VM
Start-VM -VMName SRV2

# Once SRV2 is up and running, 
# log into SRV2 as Administrator and create a new S: volume on the new disk
# Initialize the disk
Get-Disk | 
  Where-Object PartitionStyle -eq Raw |
    Initialize-Disk -PartitionStyle GPT  
    
# Create a s: volume in disk 3
$NVHT1 = @{
  DiskNumber   = 3 
  FriendlyName = 'iSCSI' 
  FileSystem   = 'NTFS' 
  DriveLetter  = 'S'
}
New-Volume @NVHT1
################

 
#   START OF SCRIPT

# Run this on SRV2

# 1. Instalubg the iSCSI target feature on SRV2
Install-Module -Name WindowsCompatibility -Force
Import-WinModule ServerManager
Install-WindowsFeature FS-iSCSITarget-Server -IncludeManagementTools

# 2. Exploring iSCSI target server settings:
Import-WinModule -Name  IscsiTarget
Get-IscsiTargetServerSetting

# 3. Creating a folder on SRV2 to hold a iSCSI virtual disk
$NIHT = @{
  Path        = 'S:\iSCSI' 
  ItemType    = 'Directory'
  ErrorAction = 'SilentlyContinue'
}
New-Item @NIHT | Out-Null

# 4. Creating an iSCSI virtual disk
Import-WinModule -Name IscsiTarget
$LP = 'S:\iSCSI\SalesData.Vhdx'
$LN = 'SalesTarget'
$VDHT = @{
  Path        = $LP
  Description = 'LUN For Sales'
  SizeBytes   = 500MB
}
New-IscsiVirtualDisk @VDHT

# 5. Creating the iSCSI target on SRV2
$THT = @{
  TargetName   = $LN
  InitiatorIds = 'IQN:*'
}
New-IscsiServerTarget @THT

# 6. Creating iSCSI disk target mapping on SRV2
Add-IscsiVirtualDiskTargetMapping -TargetName $LN -Path $LP

##
## Run remaining on FS1 (iSCSI initiator system)
##


# 7. Configuring the iSCSI service to auto start, then start the service 
Install-Module WindowsCompatibility -Force
Set-Service MSiSCSI -StartupType 'Automatic'
Start-Service MSiSCSI

# 8. Adding Multipath IO to FS1
Import-WinModule -Name ServerManager
Install-WindowsFeature -Name Multipath-IO -IncludeManagementTools
Restart-Computer -ComputerName FS1 -Force

# 9. After reboot, Setup portal to SRV2
Import-Winmodule -Name Iscsi
$PHT = @{
  TargetPortalAddress     = 'SRV2.Reskit.Org'
  TargetPortalPortNumber  = 3260
}
New-IscsiTargetPortal @PHT
                   
# 10. Find and view the SalesTarget on portal
$Target  = Get-IscsiTarget 
$Target 

# 11. Connecting to the target on SRV2
$CHT = @{
  TargetPortalAddress = 'SRV2.Reskit.Org'
  NodeAddress         = $Target.NodeAddress
}
Connect-IscsiTarget  @CHT
                    
# 12. Viewing iSCSI disk from FST on SRV2
$ISD =  Get-Disk | 
  Where-Object BusType -eq 'iscsi'
$ISD | 
  Format-Table -AutoSize

# 13. Turn disk online and make R/W
$ISD | 
  Set-Disk -IsOffline  $False
$ISD | 
  Set-Disk -Isreadonly $False

# 14. Formatting the volume on FS1
$NVHT = @{
  FriendlyName = 'SalesData'
  FileSystem   = 'NTFS'
  DriveLetter  = 'S'
}
$ISD | 
  New-Volume @NVHT
  
# 15. Using the iSCSI drive from FS1
New-Item -Path S:\  -Name SalesData -ItemType Directory |
  Out-Null
'Testing 1-2-3' | Out-File -FilePath S:\SalesData\Test.Txt
Get-ChildItem S:\SalesData

####################




# Undo: ignore for testing
Get-IscsiServerTarget | Remove-IscsiServerTarget
Get-IscsiVirtualDisk | Remove-IscsiVirtualDisk
Remove-item $LP
