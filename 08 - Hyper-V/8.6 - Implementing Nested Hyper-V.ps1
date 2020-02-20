# 8.6 - Implementing nested Hyper-V
#
# Run on HV1

#  1. Stop HVDirect VM
$VMName = 'HVDIRECT'
Stop-VM -VMName $VMName

# 2. Change the VM's processor to support virtualization
$VMName = 'HVDIRECT'
$VMHT = @{
  VMName                         = $VMName
  ExposeVirtualizationExtensions = $true
  Count                          = 2
}
Set-VMProcessor @VMHT
Get-VMProcessor -VMName $VMName |
    Format-Table -Property Name, Count,
                           ExposeVirtualizationExtensions

# 3. Enable MAC Address spoofing on the virtual NIC                           
Get-VM -VMName $VMName | 
  Get-VMNetworkAdapter | 
    Set-VMNetworkAdapter -MacAddressSpoofing On

# 4. Restart the VM
Start-VM -VMName $VMName
Wait-VM  -VMName $VMName -For Heartbeat
Get-VM   -VMName $VMName

# 5. Create credentials for HVDirect
$User = 'Reskit\Administrator'
$PHT = @{
  String      = 'Pa$$w0rd'
  AsPlainText = $true
  Force       = $true
}
$PSS  = ConvertTo-SecureString @PHT
$Type = 'System.Management.Automation.PSCredential'
$CredRK = New-Object -TypeName $Type -ArgumentList $User,$PSS

# 6.  Install Hyper-V inside the HVDirect VM
$SB = {
  Install-WindowsFeature -Name Hyper-V -IncludeManagementTools
}
$IHT  = @{
  VMName      =  $VMName
  ScriptBlock = $SB 
  Credential  = $CredRK
}
Invoke-Command @IHT

# 7. Restart the VM to finish adding Hyper-V
Stop-VM  -VMName $VMName
Start-VM -VMName $VMName
Wait-VM  -VMName $VMName -For IPAddress
Get-VM   -VMName $VMName

# 8. Check Hyper-V inside HVDirect VM
$SB = {
  Get-WindowsFeature *Hyper* |
    Format-Table Name, InstallState
  Get-Service VM*
}
Invoke-Command -VMName $VMName -ScriptBlock $SB -Credential $CredRK
