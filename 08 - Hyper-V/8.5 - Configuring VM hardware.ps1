# 8.5 - Configuring VM Hardware
#
# Run on HV1, using HVDirect VM

# 1. Turn off the HVDirect VM
$VMName = 'HVDirect'
Stop-VM -VMName $VMName 
Get-VM -VMName $VMName

# 2. Set the StartupOrder in the VM's BIOS
$Order = 'IDE','CD','LegacyNetworkAdapter','Floppy'
Set-VMBios -VmName $VMName -StartupOrder $Order
Get-VMBios $VMName

# 3. Set CPU count for HVDirect
Set-VMProcessor -VMName $VMName -Count 2
Get-VMProcessor -VmName $VMName |
  Format-Table VMName, Count

# 4. Set VM memory
$VMHT = [ordered] @{
  VMName               = $VMName
  DynamicMemoryEnabled = $true
  MinimumBytes         = 768MB
  StartupBytes         = 2GB
  MaximumBytes         = s4GB
}
Set-VMMemory @VMHT
Get-VMMemory -VMName $VMName

# 5. Add a ScsiController to the VM
Add-VMScsiController -VMName $VMName
Get-VMScsiController -VMName $VMName

# 6. Restart the HVDirect VM
Start-VM -VMName $VMName
Wait-VM -VMName $VMName -For IPAddress

# 7. Create a new VHDX file
$VHDPath = 'C:\Vm\Vhds\HVDirect-D.VHDX'
New-VHD -Path $VHDPath -SizeBytes 8GB -Dynamic

# 8. Add the VHD to the ScsiController
$VHDHT = @{
    VMName            = $VMName
    ControllerType    = 'SCSI'
    ControllerNumber  =  0
    ControllerLocation = 0
    Path               = $VHDPath
}
Add-VMHardDiskDrive @VHDHT

# 9. Get SCSI Disks in the VM
Get-VMScsiController -VMName $VMName |
  Select-Object -ExpandProperty Drives




  