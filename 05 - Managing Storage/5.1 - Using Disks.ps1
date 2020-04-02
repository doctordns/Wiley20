# 5.1 - Manaing Physical Disks and Volumes
#
# Run on SRV1

# SRV1 needs two extra disks that are 'bare' and just added to the VM

# 0. Add 2 VHDs to SRV1 VM
#    Run this on the Hyper-V VM Host

# Stop the VM
Stop-VM -VMName SRV1

# Get File location for the disk in this VM
$VM = Get-VM -VMName SRV1
$Par = Split-Path -Path $VM.HardDrives[0].Path

# Create two VHDx for F and G
$NewPath1 = Join-Path -Path $par -ChildPath FDrive.VHDX
$NewPath2 = Join-Path -Path $par -ChildPath GDrive.VHDX
$D1 = New-VHD -Path $NewPath1 -SizeBytes 128GB -Dynamic
$D2 = New-VHD -Path $NewPath2 -SizeBytes 128GB -Dynamic

# Add a new SCSI Controller to SRV1
$C = (Get-VMScsiController -VMName SRV1)
Add-VMScsiController -VMName SRV1

# Add first disk to VM
$HDHT = @{ 
  Path               = $NewPath1
  VMName             = 'SRV1'
  ControllerType     = 'SCSI'
  ControllerNumber   = $C.count
  ControllerLocation = 0 
}
Add-VMHardDiskDrive @HDHT
# Add second disk to VM
$HDHT.Path = $NewPath2
$HDHT.ControllerLocation = 1
Add-VMHardDiskDrive @HDHT

# Start the VM
Start-VM -VMName SRV1

### start of main script
### run in SRV1 after it reboots

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

# 4. Create a F: volume in Disk 1
$NVHT1 = @{
  DiskNumber   = 1 
  FriendlyName = 'Storage(F)' 
  FileSystem   = 'NTFS' 
  DriveLetter  = 'F'
}
New-Volume @NVHT1

# 5. Now create a partition in Disk 2
New-Partition -DiskNumber 2  -DriveLetter G -Size 42gb

# 6. Create a second partition H:
New-Partition -DiskNumber 2  -DriveLetter H -UseMaximumSize

# 7. View Volumes on SRV1
Get-Volume |
  Sort-Object -Property DriveLetter

# 8. Format G: and H:
# Format G:
$NVHT1 = @{
  DriveLetter        = 'G'
  FileSystem         = 'NTFS' 
  NewFileSystemLabel = 'Logs'
}
Format-Volume @NVHT1
# Format H:
$NVHT2 = @{
  DriveLetter        = 'H'
  FileSystem         = 'NTFS' 
  NewFileSystemLabel = 'Music'
}
Format-Volume @NVHT2

# 9. Get partitions on SRV1
Get-Partition |
  Sort-Object -Property DriveLetter |
    Format-Table -Property DriveLetter, Size, Type

# 10. Get Volumes on SRV1
Get-Volume | 
  Sort-Object -Property DriveLetter
