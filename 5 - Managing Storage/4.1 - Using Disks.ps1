# Recipe 4.1 - Manaing physical Disks and Volumes
#
# Run on SRV1
# SRV1 has 2 extra disks that are 'bare' and just added to the VM

# 0. Add 2 VHDs to SRV1 VM
#    Run this on the Hyper-V VM Host
# Stop the vm
Stop-VM -VMName SRV1
# Get File location for the disk in this VM
$VM = Get-VM -VMName SRV1
$Par = Split-Path -Path $VM.HardDrives[0].Path
# Create two VHDx for G and H
$NewPath1 = Join-Path -Path $par -ChildPath GDrive.VHDX
$NewPath2 = Join-Path -Path $par -ChildPath HDrive.VHDX
$D1 = New-VHD -Path $NewPath1 -SizeBytes 128GB -Dynamic
$D2 = New-VHD -Path $NewPath2 -SizeBytes 128GB -Dynamic
# Add to VM
$HDHT = @{ 
  Path               = $NewPath1
  VMName             = 'SRV1'
  ControllerType     = 'SCSI'
  ControllerNumber   = 0
  ControllerLocation = 0 
}
$HDHT = @{ 
  Path               = $NewPath1
  VMName             = 'SRV1'
  ControllerType     = 'SCSI'
  ControllerNumber   = 0
  ControllerLocation = 0 
}
Add-VMHardDiskDrive @HDHT
# Add second disk
$HDHT.Path = $NewPath2
$HDHT.ControllerLocation = 1
Add-VMHardDiskDrive @HDHT
# Start the VM
Start-VM -VMName SRV1

# 1. Get physical disks on this system:
Get-Disk |
  Format-Table -AutoSize

# 2. Initialize the disks
Get-Disk | 
  Where-Object PartitionStyle -eq Raw |
    Initialize-Disk -PartitionStyle GPT 

# 3. Re-display disks
Get-Disk |
  Format-Table -AutoSize

# 4. Create a F: volume in disk 1
$NVHT1 = @{
  DiskNumber   = 1 
  FriendlyName = 'Storage(F)' 
  FileSystem   = 'NTFS' 
  DriveLetter  = 'F'
}
New-Volume @NVHT1

# 5. Now create a volume in Disk 2
New-Partition -DiskNumber 2  -DriveLetter G -Size 42gb

# 6. Create a second partition H:
New-Partition -DiskNumber 2  -DriveLetter H -UseMaximumSize

# 7. View Volumes on SRV1
Get-Volume |
  Sort-Object -Property DriveLetter

# 8. Format G: and H:
$NVHT1 = @{
  DriveLetter        = 'G'
  FileSystem         = 'NTFS' 
  NewFileSystemLabel = 'Logs'
}
Format-Volume @NVHT1
$NVHT2 = @{
  DriveLetter        = 'H'
  FileSystem         = 'NTFS' 
  NewFileSystemLabel = 'Music'
}
Format-Volume @NVHT2

# 9. Get partitions on SRV1
Get-Partition | Format-Table -AutoSize
  Sort-Object -Property DriveLetter |
    Format-Table -Property DriveLetter, Size, Type

# 10. Get Volumes on SRV1
Get-Volume | 
  Sort-Object -Property DriveLetter
