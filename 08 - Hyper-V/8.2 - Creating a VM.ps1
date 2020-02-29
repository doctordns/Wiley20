# 8.2 - Creating a Hyper-V VM

# Run on HV1 after setting up as in 8.1

# 1. Set up the VM name and paths
$VMname      = 'HVDirect'
$VMLocation  = 'C:\VM\VMs'
$VHDlocation = 'C:\VM\Vhds'
$VHDPath     = "$VHDlocation\HVDirect.Vhdx"
$ISOPath     = 'C:\ISO\WinSrv2019.ISO'

# 2. Verify drive contents
If (-Not (Test-Path -Path $ISOPath)) {
    Throw "ISO Image [$ISOPath] NOT found"
}

# 3. Import the DISM Module and Display the OSs on this ISO
Import-Module -Name DISM -WarningAction SilentlyContinue

# 4. Mount ISO Image 
Mount-DiskImage -ImagePath $ISOPath

# 5. Get details and Display ISO image contents and Dismount the ISO
$ISOImage = Get-DiskImage -ImagePath $ISOPath | Get-Volume
$ISODrive = [string] $ISOImage.DriveLetter + ":"
Get-WindowsImage -ImagePath $ISODrive\sources\install.wim | 
  Format-Table -Property ImageIndex, Imagename, Imagedescription -Wrap
  
Dismount-DiskImage -ImagePath $ISOPath | Out-Null

# 6.  Create a new VM
New-VM -Name $VMname -Path $VMLocation -MemoryStartupBytes 1GB

# 7. Create a virtual disk file for the VM
New-VHD -Path $VhdPath -SizeBytes 128GB -Dynamic | Out-Null

# 8. Add the virtual hard drive to the VM
Add-VMHardDiskDrive -VMName $VMname -Path $VhdPath

# 9. Set ISO image in the VM's DVD drive
$IHT = @{
  VMName           = $VMName
  ControllerNumber = 1
  Path             = $ISOPath
}
Set-VMDvdDrive @IHT

# 10. Start the VM
Start-VM -VMname $VMname 

# 11 Complete a manual Installation
#    DO IT VIA THE GUI

# 12. View the results
Get-VM -Name $VMname 
