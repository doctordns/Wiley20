# 4.3 - Manage Storage replica
# 
# Run on SRV1, with SRV2, DC1 online

# 0. Add a VHDs to SRV2 VM
#    Run this on the Hyper-V VM Host
# Stop the vm
Stop-VM -Name SRV2
# Get File location for the disk in this VM
$VM = Get-VM -VMName SRV2
$Par = Split-Path -Path $VM.HardDrives[0].Path
# Create two VHDx for G and H
$NewPath1 = Join-Path -Path $par -ChildPath FDrive.VHDX
$NewPath2 = Join-Path -Path $Par -ChildPath GDrive.VHDX
$D1 = New-VHD -Path $NewPath1 -SizeBytes 128GB -Dynamic
$D2 = New-VHD -Path $NewPath2 -SIzebytes 128GB -Dynamic
# Add First to VM
$HDHT = @{ 
  Path               = $NewPath1
  VMName             = 'SRV2'
  ControllerType     = 'SCSI'
  ControllerNumber   = 0
  ControllerLocation = 0 
}
Add-VMHardDiskDrive @HDHT   # Add 1st disk to vm
# Add Secon to VM
$HDHT.Path               = $NewPath2
$HDHT.ControllerLocation = 1
Add-VMHardDiskDrive @HDHT   # Add 2nd disk to VM
Start-VM -VMName SRV2

# After  reboot, run this on SRV2 as administrator
Get-Disk | 
  Where-Object PartitionStyle -eq Raw |
    Initialize-Disk -PartitionStyle GPT 
$NVHT = @{
  DiskNumber   = 1 
  FriendlyName = 'Storage(F)' 
  FileSystem   = 'NTFS' 
  DriveLetter  = 'F'
}
New-Volume @NVHT  # Add 1st new disk
$NVHT.DiskNumber   = 2
$NVHT.FriendlyName = 'Log'
$NVHT.DriveLetter  = 'G'
New-Volume @NVHT  # Add 2nd new disk
# Add Windows Compatibility module *=(in case)
Install-Module WindowsCompatibility
###########################

#  Now Logon to SRV1 to complete this script

# 1. Create Content on F:
1..100 | ForEach-Object {
  $NF = "F:\CoolFolder$_"
  New-Item -Path $NF -ItemType Directory | Out-Null
  1..100 | ForEach-Object {
    $NF2 = "$NF\CoolFile$_"
    "Cool File" | Out-File -PSPath $NF2
  }
}

# 2. Show what is on F: locally
Get-ChildItem -Path F:\ -Recurse | Measure-Object

# 3. And examine the same drives remotely on SRV2
$SB = {
  Get-ChildItem -Path F:\ -Recurse |
    Measure-Object
}
Invoke-Command -ComputerName SRV2 -ScriptBlock $SB

# 4. Add storage replica feature to SRV1
Import-WinModule ServerManager
$Features = "fs-fileserver", "storage-replica", "RSAT-Storage-Replica"
Add-WindowsFeature -Name Storage-Replica -IncludeManagementTools

# 5. Restart SRV1 to finish the installation process
Restart-Computer

# 6. Add SR Feature to SRV2
$SB = {
  Add-WindowsFeature -Name Storage-Replica | Out-Null
}
Invoke-Command -ComputerName SRV2 -ScriptBlock $SB

# 7. And restart SRV2 Waiting for the restart
$RSHT = @{
  ComputerName = 'SRV2'
  Force        = $true
}
Restart-Computer @RSHT -Wait -For PowerShell



# 8.  Test Replica 
Import-WinModule -Name StorageReplica
$TSTHT = @{
  SourceComputerName       = 'SRV1.Reskit.Org'
  SourceVolumeName         = 'F:' 
  SourceLogVolumeName      = 'G:'
  DestinationComputerName  = 'SRV2.Reskit.Org' 
  DestinationVolumeName    = 'F:'
  DestinationLogVolumeName = 'G'
  DurationInMinutes        = 15 
  ResultPath               = 'C:\Foo'
  Verbose                  = $true
  IgnorePerfTests          = $true
}
Test-SRTopology @TSTHT

# 9. View the Report
& "C:\Foo\TestSrTopologyReport-2019-08-12-12-18-27.html"


# 10. Create an SR Replica
$SRHT = @{
  SourceComputerName       = 'SRV1'
  SourceRGName             = 'SRV1RG'
  SourceVolumeName         = 'F:'
  SourceLogVolumeName      = 'G:'
  DestinationComputerName  = 'SRV2'
  DestinationRGName        = 'SRV2RG'
  DestinationVolumeName    = 'F:'
  DestinationLogVolumeName = 'G:'
  LogSizeInBytes           = 2gb
}
New-SRPartnership @SRHT -Verbose 

# 11. View it
Get-SRPartnership 

# 12. And examine the same drives remotely on SRV2
$SB = {
  Get-Volume |
    Sort-Object -Property DriveLetter |
      Format-Table   
}
Invoke-Command -ComputerName SRV2 -ScriptBlock $SB


# 13. Reverse the replication
$SRHT2 = @{ 
  NewSourceComputerName   = 'SRV2'
  SourceRGName            = 'SRV2RG' 
  DestinationComputerName = 'SRV1'
  DestinationRGName       = 'SRV1RG'
  Confirm                 = $false
}
Set-SRPartnership @SRHT2


# 14 View RG
Get-SRPartnership

# 15. Examine the same drives remotely on SRV2
$SB = {
  Get-Volume |
    Sort-Object -Property DriveLetter |
      Format-Table 
    Get-ChildItem -Path F:\ -Recurse | Measure-Object |
      Format-List
        
}
Invoke-Command -ComputerName SRV2 -ScriptBlock $SB

