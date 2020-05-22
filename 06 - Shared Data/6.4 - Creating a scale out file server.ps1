#  6.3 - Create SOFS
# This recipe is run on FS2, but involves FS1 and SRV2
# ISCSI initiator is already setup on FS1 
# ISCSI target is already setup on SRV2

#  RUN ON FS2

# 1. Setup FS2 to support ISCSI
# Adjust the iSCSI service to auto start, then start the service.
Set-Service MSiSCSI -StartupType 'Automatic'
Start-Service MSiSCSI

# 2. Setup iSCSI portal to SRV2
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

# 3. Add File Server features to FS2
Import-Module -Name ServerManager -WarningAction SilentlyContinue
$Features = 'FileAndStorage-Services',
            'File-Services',
            'FS-FileServer'
Install-WindowsFeature -Name $Features -IncludeManagementTools |
  Out-Null

# 4. Adding clustering features to FS1/FS2
Import-Module -Name ServerManager -WarningAction SilentlyContinue
$IHT = @{
  Name                   = 'Failover-Clustering'
  IncludeManagementTools = $true
}
Install-WindowsFeature -ComputerName FS2 @IHT
Install-WindowsFeature -ComputerName FS1 @IHT

# 5. Restarting both FS1, FS2
Restart-Computer -ComputerName FS1 -Force
Restart-Computer -ComputerName FS2 -Force

# 6. Testing Cluster nodes
Import-Module -Name FailoverClusters -WarningAction SilentlyContinue
$CheckOutput = 'C:\Foo\Clustercheck'
Test-Cluster  -Node FS1, FS2  -ReportName $CheckOutput | Out-Null

# 7. View the cluster Validation test results
$COFILE = "$CheckOutput.htm"
Invoke-Item  -Path $COFILE

# 8.  Creating the cluster
$NCHT = @{
  Name          = 'FS'
  Node          = 'FS1.Reskit.Org', 'FS2.Reskit.Org'
  StaticAddress = '10.10.10.100'
  NoStorage     = $true
}
New-Cluster @NCHT | Out-Null

# 9. Configure a share on DC1 to act as quorum
$SBDC1 = {
  New-Item -Path c:\Quorum -ItemType Directory
  New-SMBShare -Name Quorum -Path C:\Quorum -FullAccess Everyone
}
Invoke-Command -ComputerName DC1 -ScriptBlock $SBDC1 | Out-Null

# 10. Set the cluster Witness
Set-ClusterQuorum -NodeAndFileShareMajority \\DC1\Quorum

# 11. Ensuring iSCSI disks are connected
$SB = {
  Get-ISCSITarget | 
    Connect-IscsiTarget -ErrorAction SilentlyContinue
}
Invoke-Command  -ComputerName FS1 -ScriptBlock $SB
Invoke-Command  -ComputerName FS2 -ScriptBlock $SB

# 12. Adding the iSCSI disk to the cluster
Get-Disk | 
  Where-Object BusType -eq 'iSCSI' | 
    Add-ClusterDisk

# 13. Move disk into the CSV
Add-ClusterSharedVolume -Name 'Cluster Disk 1'

# 14. Add SOFS role to Cluster
Import-Module -Name ServerManager -WarningAction SilentlyContinue
Add-WindowsFeature File-Services -IncludeManagementTools | Out-Null
Add-ClusterScaleOutFileServerRole -Cluster FS | Out-Null

# 15. Create a folder and give Sales Access to the folder
Install-Module -Name NTFSSecurity -Force | Out-Null
$HvFolder = 'C:\ClusterStorage\Volume1\HVData'
New-Item -Path $HvFolder -ItemType Directory |
              Out-Null
$ACCHT = @{
  Path        = $HvFolder
  Account     = 'Reskit\Sales'
  AccessRights = 'FullControl'
}              
Add-NTFSAccess  @ACCHT 

# 16. Adding a Continuously Available share to the entire cluster
$SMBSHT2 = @{
  Name                  = 'SalesHV'
  Path                  = $HvFolder
  Description           = 'Sales HV (CA)'
  FullAccess            = 'Reskit\Sales'
  ContinuouslyAvailable = $true 
}              
New-SMBShare  @SMBSHT2 

# 17. View Shares on FS1 and FS2
Get-SmbShare    # FOR FS1
Invoke-Command -ComputerName FS2 -ScriptBlock {Get-SmbShare}


