# 8.3 - Using PS Direct with Hyper-V
#
# Run on HV1 after HVDirect has been created on HV1

# 1. Create a credential object for Reskit\Administrator:
$RKAN   = 'Localhost\Administrator'
$PS     = 'Pa$$w0rd'
$RKP    = ConvertTo-SecureString -String $PS -AsPlainText -Force
$CREDHT = @{
           TypeName     = 'System.Management.Automation.PSCredential'
           Argumentlist = $RKAN, $RKP
}
$RKCred = New-Object @CREDHT
$VMNAME = 'HVDirect'

# 2. Display the details of the HVDirect VM
Get-VM -Name $VMNAME

# 3. Invoke a command on the VM, specifying VM name:
$SBHT = @{
  VMName      = $VMNAME
  Credential  = $RKCred
  ScriptBlock = {hostname}
}
Invoke-Command @SBHT

# 4. Invoke a command based on VMID:
$VMID = (Get-VM -VMName $VMNAME).VMId.Guid
Invoke-Command -VMid $VMID -Credential $RKCred  -ScriptBlock {ipconfig}

