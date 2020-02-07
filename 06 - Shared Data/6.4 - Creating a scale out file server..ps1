#  6.3 - Create SOFS
# This recipe is run on FS1, but involves FS2 and SRV2
# ISCSI initiator is setup on FS1 
# ISCSI target setup on SRV2

# 1. Setup FS2 to support ISCSI
# Adjust the iSCSI service to auto start, then start the service and reboot.
$SB1 = {
  Set-Service MSiSCSI -StartupType 'Automatic'
  Start-Service MSiSCSI
}
Invoke-Command -ComputerName FS2 -ScriptBlock $SB1 | Out-Null

 # 2. Setup iSCSI portal to SRV2
 $SB2 = {
   $PHT = @{
     TargetPortalAddress     = 'SRV2.Reskit.Org'
     TargetPortalPortNumber  = 3260
    }
    New-IscsiTargetPortal @PHT
    #  Get the SalesTarget on portal
    $Target  = Get-IscsiTarget 
    # Connect to the target on SRV2
    $CHT = @{
      TargetPortalAddress = 'SRV2.Reskit.Org'
      NodeAddress         = $Target.NodeAddress
    }
    Connect-IscsiTarget  @CHT
    $ISD =  Get-Disk | 
      Where-Object BusType -eq 'iscsi'
      $ISD | 
        Set-Disk -IsOffline  $False
      $ISD | 
        Set-Disk -Isreadonly $False
}
Invoke-Command -ComputerName FS2 -ScriptBlock $SB2 | Out-Null

# 3. Adding clustering features to FS1/FS1
Import-Module ServerManager -WarningAction SilentlyContinue
$IHT = @{
  Name                    = 'Failover-Clustering'
  IncludeManagementTools = $true
}
Install-WindowsFeature -ComputerName FS2 @IHT
Install-WindowsFeature -ComputerName FS1 @IHT

# 4. Restarting both FS1, FS2
Restart-Computer -ComputerName FS2 -Force
Restart-Computer -ComputerName FS1 -Force

# 5. Testing Cluster Nodes
Import-Module -Name FailoverClusters
$CHECKOUTPUT = 'C:\Foo\Clustercheck'
Test-Cluster  -Node FS1, FS2  -ReportName $CHECKOUTPUT

# 6. View Validation test results
$COFILE = "$CheckOutput.htm"
Invoke-Item  -Path $COFILE

# 7.  Creating The Cluster
$NCHT = @{
  Name          = 'FS'
  Node          = 'FS1.Reskit.Org', 'FS2.Reskit.Org'
  StaticAddress = '10.10.10.100'
}
New-Cluster @NCHT | Out-Null

# 8. Ensuring iSCSI disks are connected
$SB = {
  Get-ISCSITarget | 
  Connect-IscsiTarget -ErrorAction SilentlyContinue
}
Invoke-Command  -ComputerName FS1 -ScriptBlock $SB
Invoke-Command  -ComputerName FS2 -ScriptBlock $SB

# 9. Viewing the iSCSI Target
Get-ClusterAvailableDisk 

# 10. Adding iSCSI disk to the cluster
Get-Disk | 
  Where-Object BusType -eq 'iSCSI'| 
    Add-ClusterDisk

# 12. Add file server role
$ACFSHT = {
  Cluster = 'FS'
  Name    = 'RKFS'
  Storage = 'Cluster Disk 1' 
}
Add-ClusterFileServerRole  @ACFSHT


# 12. Create a folder and give Sales Access to the folder
$HvFolder = 'C:\ClusterStorage\Volume1\HVData'
New-Item -Path $HvFolder -ItemType Directory |
              Out-Null
Add-NTFSAccess -Path $HvFolder -Account Reskit\Sales -AccessRights FullControl

# 13. Ensure CSV managed by node FS1
Move-ClusterSharedVolume -Name 'Cluster Disk 1' -Node 'FS1'

# 11. Add SOFS role to Cluster
Import-WinModule -Name ServerManager
Add-WindowsFeature File-Services -IncludeManagementTools
Add-ClusterScaleOutFileServerRole -Cluster FS | Out-Null

# 12. Adding a Continuously Available share to the entire cluster
$SMBSHT2 = @{
  Name                  = 'SalesHV'
  Path                  = $HvFolder
  Description           = 'Sales HV (CA)'
  FullAccess            = 'Reskit\Sales'
  ContinuouslyAvailable = $true 
}              
New-SMBShare  @SMBSHT2

# 13. View Shares
Get-SmbShare


<#  Remove it
Get-SMBShare -name SalesData | Remove-SMBShare -Confirm:$False
Get-SMBShare -name HVShare | Remove-SMBShare -Confirm:$False

get-clusterresource | Stop-ClusterResource

Get-ClusterSharedVolume | Remove-ClusterSharedVolume
Get-Clusterresource | stop-clusterresource
Get-ClusterGroup -Name salesfs | remove-clusterresource
Get-ClusterResource | remove-clusterresource -Force
Remove-Cluster  -force -cleanupad
#>

# later
Add-ClusterSharedVolume -Name HVCSV
