# 8.1 - Installing and configuring Hyper-V

# Run on HV1

# If HV1 is a VM, configure it
# On the Hyper-V Host running HV1
Stop-VM -VMName HV1
# Enable nested virtualization and set processor count for HV1
$VMHT = @{
  VMName                         = 'HV1' 
  ExposeVirtualizationExtensions = $true
  Count                          = 4
}
Set-VMProcessor @VMHT
# Set VM Memory for HV1
$VMHT = [ordered] @{
    VMName               = 'HV1'
    DynamicMemoryEnabled = $true
    MinimumBytes         = 1GB
    StartupBytes         = 2GB
    MaximumBytes         = 6GB
}
Set-VMMemory @VMHT
Start-VM -VMName HV1

#  Start of Script


# 1. Install the Hyper-V feature on HV1
Import-Module -Name ServerManager -WarningAction SilentlyContinue
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools

# 2. Reboot HV1 to complete the installation
Restart-Computer -ComputerName HV1

# 3. Create new folders to hold VM details and disks
$VMS  = 'C:\VM\VMS'
$VHDS = 'C:\VM\VHDS\'
New-Item -Path $VMS  -ItemType Directory -Force | Out-Null
New-Item -Path $VHDS -ItemType Directory -force | Out-Null

# 4. Build Hash Table to Configure the VM Host
$VMCHT = @{
# Where to store VM configuration files  
  VirtualMachinePath  = $VMS
# Where to store VHDx files
  VirtualHardDiskPath = $VHDS
# Enable NUMA spanning
  NumaSpanningEnabled = $true
# Enable Enhanced Session Mode
  EnableEnhancedSessionMode = $true
# Specify Resource metering save interval
  ResourceMeteringSaveInterval  = (New-TimeSpan -Hours 2 )
}
Set-VMHost @VMCHT

# 5. Review key VMHost settings
Get-VMHost  |
  Format-Table -Property 'Name', 'V*Path','Numasp*', 'Ena*','RES*'
  