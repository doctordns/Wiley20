# 8.8 - Configuring VM replication
#
# Run on HV1

# 0.1 Configure HV2 VM from the VM host
# If HV2 is a VM, configure it on the Hyper-V Host running HV2
# Stop the VM
Stop-VM -VMName HV2
# Enable nested virtualization and set processor count for HV2
$VMHT = @{
  VMName                         = 'HV2' 
  ExposeVirtualizationExtensions = $true
  Count                          = 4
}
Set-VMProcessor @VMHT
# Set VM Memory for HV1
$VMHT = [ordered] @{
    VMName               = 'HV2'
    DynamicMemoryEnabled = $true
    MinimumBytes         = 768MB
    StartupBytes         = 2GB
    MaximumBytes         = 4GB
}
Set-VMMemory @VMHT
# Configure Hyper-V Host on HV2
# Create folders to hold VM details and disks
$VMS  = 'C:\VM\VMS'
$VHDS = 'C:\VM\VHDS\'
New-Item -Path $VMS  -ItemType Directory -Force | Out-Null
New-Item -Path $VHDS -ItemType Directory -force | Out-Null
# Build Hash Table to Configure the VM Host
$VMCHT = @{
# Where to store VM configuration files on
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
# Create external switch on HV2
$NIC = Get-NetIPConfiguration | Select-Object -First 1
New-VMSwitch -Name External -NetAdapterName $NIC.InterfaceAlias
Start-VM -VMName HV2
Wait-VM -VMName HV2 -For IPAddress

# 0.2 Login to HV2 to add Hyper-V feature to HV2
# 
# Install the Hyper-V feature on HV2
Import-Module -Name Servermanager -WarningAction SilentlyContinue
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools
# Reboot HV2 to complete the installation of Hyper-V
Restart-Computer -ComputerName HV2

### main Script starts here
### login to HV2 to run these commands from elevated console

# 1. Configure HV1 and HV2 to be trusted for delegation in AD on DC1
$SB1 = {
  Set-ADComputer -Identity HV1 -TrustedForDelegation $True
}
Invoke-Command -ComputerName DC1 -ScriptBlock $SB1
$SB2 = {
  Set-ADComputer -Identity HV2 -TrustedForDelegation $True}
Invoke-Command -ComputerName DC1 -ScriptBlock $SB2

# 2. Reboot the HV1 and HV2
Restart-Computer -ComputerName HV1 -Force
Restart-Computer -ComputerName HV2 -Force

# 3. Once both systems are restarted, logon back to HV2,
#    set up both servers as a replication server
$VMRHT = @{
   ReplicationEnabled              = $true
   AllowedAuthenticationType       = 'Kerberos'
   KerberosAuthenticationPort      = 42000
   DefaultStorageLocation          = 'C:\Replicas'
   ReplicationAllowedFromAnyServer = $true
   ComputerName                    = 'HV1', 'HV2'
}
Set-VMReplicationServer @VMRHT

# 4. Enable HVDirect on HV1 to be a replica source
$VMRHT = @{
  VMName            = 'HVDirect'
  Computer          = 'HV1'
  ReplicaServerName = 'HV2'
  ReplicaServerPort = 42000
 AuthenticationType = 'Kerberos'
 CompressionEnabled = $true
 RecoveryHistory    = 5
}
Enable-VMReplication  @VMRHT

# 5. View the replication status of HV1 and HV2
Get-VMReplicationServer -ComputerName HV1
Get-VMReplicationServer -ComputerName HV2

# 6. Check HVDirect on HV1
Get-VM -ComputerName HV1 -VMName HVDirect

# 7. Start the initial replication from HV1 to HV2
Start-VMInitialReplication -VMName HVDirect -ComputerName HV1

# 8. Examine the initial replication state on HV1 just after
#    you start the initial replication
Measure-VMReplication -ComputerName HV2
#  Now wait till replication is complete - this can take a  while

# 9. Wait for replication to finish, then examine the
#    replication status on HV2
Measure-VMReplication -ComputerName HV2

# 10. Test HVDirect failover from HV1 to HV2
$SB = {
  $VM = Start-VMFailover -AsTest -VMName HVDirect -Confirm:$false
  Start-VM $VM
}
Invoke-Command -ComputerName HV2 -ScriptBlock $SB

# 11. View the status of VM on HV2
Get-VM -ComputerName HV2

# 12. Get VM details in VM replica source
$RKUN   = 'Reskit\Administrator'
$PS     = 'Pa$$w0rd'
$RKP    = ConvertTo-SecureString -String $PS -AsPlainText -Force
$CREDHT = @{
  TypeName     = 'System.Management.Automation.PSCredential'
  Argumentlist = $RKUN, $RKP
}
$RKCred = New-Object @CREDHT
$SB1 = {
  $SB1a = $ICMHT = @{
    VMName       = 'HVdirect' 
    ScriptBlock  = {hostname;ipconfig}
    Credential   = $using:RKCred
  }
  Invoke-Command @SB1a
}   
Invoke-Command -Computer HV1 -Script $SB1

# 13. Get VM details in replica test VM on HV2
$SB2 = {
  $SB2a = $ICMHT = @{
    VMName       = 'HVDirect - Test' 
    ScriptBlock  = {hostname;ipconfig}
    Credential   = $using:RKCred
  }
  Invoke-Command @SB2a
}   
Invoke-Command -Computer HV2 -Script $SB2

# 14. Stop the failover test
$SB3 = {
  Stop-VMFailover -VMName HVDirect
}
Invoke-Command -ComputerName HV2 -ScriptBlock $SB3

# 15. View the status of VMs on HV1 and HV2 after failover stopped
Get-VM -ComputerName HV1
Get-VM -ComputerName HV2

# 16. Set Failover IP address for HVDIrect on HV2
$NAHT = @{
  IPv4Address            = '10.10.10.142'
  IPv4SubnetMask         = '255.255.255.0'
  IPv4PreferredDNSServer = '10.10.10.10'
}
Get-VMNetworkAdapter -VMName HVDirect -ComputerName HV2 | 
  Set-VMNetworkAdapterFailoverConfiguration @NAHT 
Connect-VMNetworkAdapter -VMName HVDirect -SwitchName External

# 17. Stop VM1 on HV2 prior to performing a planned failover
Stop-VM HVdirect -ComputerName HV1

# 18. Start VM failover from HV1
Start-VMFailover -VMName HVDirect -ComputerName HV2 -Confirm:$false

# 19. Complete the failover
$CHT = @{
  VMName       = 'HVDirect'
  ComputerName = 'HV2'
  Confirm      = $false
}
Complete-VMFailover @CHT

# 20. Start the replicated VM on HV1
Start-VM -VMname HVDirect -ComputerName HV2
Wait-VM -VMName HVDirect -For IPAddress

# 21. See VMs on HV1 and HV2 after the planned failover
Get-VM -ComputerName HV1
Get-VM -ComputerName HV2

# 22. Retest Migrated HVDirect VM
$SB4 =@{
  VMName      = 'HVDirect'
  ScriptBlock = {hostname; ipconfig} 
  Credential  = $rkcred 
}
Invoke-Command @SB4 