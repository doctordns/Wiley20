# 8.4 - Configuring VM Networking
#
# Run on HV1 

# 1. Get NIC details and any IP Address from the HVDirect VM
$VMName = 'HVDirect'
Get-VMNetworkAdapter -VMName $VMName

# 2. Create a credential 
$LHAN   = 'Localhost\Administrator'
$PS     = 'Pa$$w0rd'
$LHP    = ConvertTo-SecureString -String $PS -AsPlainText -Force
$T      = 'System.Management.Automation.PSCredential'
$LHCred = New-Object -TypeName $T -ArgumentList $LHAN, $LHP

# 3. Get NIC Details from inside the VM
$VMHT = @{
    VMName      = $VMName
    ScriptBlock = {Get-NetIPConfiguration | 
                     Format-List }
    Credential  = $LHCred
}
Invoke-Command @VMHT 

# 4. Create a virtual switch on HV1
$VSHT = @{
    Name           = 'External'
    NetAdapterName = 'Ethernet'
    Notes          = 'Created on HV1'
}
New-VMSwitch @VSHT

# 5. Connect HVDirect to the switch
Connect-VMNetworkAdapter -VMName $VMName -SwitchName External

# 6. Enable spoofing From VM Host
#    Run this command on the VM Host that hosts HV1
Get-VMNetworkAdapter -VMName HV1 | 
  Set-VMNetworkAdapter -MacAddressSpoofing On

# 7. Get VM networking information
Get-VMNetworkAdapter -VMName $VMName

# 8. With HVDirect now in the network, observe the IP address in the VM
$NCHT = @{
    VMName      = $VMName
    ScriptBlock = {Get-NetIPConfiguration | Format-List}
    Credential  = $LHCred
}
Invoke-Command @NCHT

# 9. Join the Reskit Domain
# Update the script block
$NCHT.ScriptBlock = {
  $RKAdmin = 'Reskit\Administrator'
  $PS      = 'Pa$$w0rd'
  $RKPW    = ConvertTo-SecureString -String $PS -AsPlainText -Force
  $T = 'System.Management.Automation.PSCredential'
  $DomCred = New-Object -TypeName $T -ArgumentList $RKAdmin, $RKPW
  $JCHT = @{
    Domain     = 'Reskit.Org' 
    Credential = $DomCred
    NewName    = 'Tiger'
  }
  Add-Computer @JCHT
}
Invoke-Command @NCHT

# 10. Reboot and wait for the restarted VM
Restart-VM -VMName $VMName -Wait -For IPAddress -Force

# 11. Get hostname of the HVDirect VM
$RKAdmin          = 'Reskit\Administrator'
$PS               = 'Pa$$w0rd'
$RKPW             = ConvertTo-SecureString -String $PS -AsPlainText -Force
$T                = 'System.Management.Automation.PSCredential'
$DomCred          = New-Object -TypeName $T -ArgumentList $RKAdmin, $RKPW
$NCHT.Credential  = $DomCred
$NCHT.ScriptBlock = {hostname}
Invoke-Command @NCHT
