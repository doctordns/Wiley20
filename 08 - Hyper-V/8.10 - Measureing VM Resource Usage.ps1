# 8.9 - Measuring VM Resource Usage

#  Run on HV2 
#  Ensure HVDirect is running on HV2.

# 1. Get-VMs on HV2
$VM = Get-VM 
$VM

# 2. Enable resource monitoring of HVDirect
Enable-VMResourceMetering -VM $VM

# 3. Start VM if needed
If ($VM.State -ne 'Running') {
  Start-VM $VM 
  Wait-VM -VM $VM -FOR IPAddress 
}

# 4. Create Credentials for HVDirect
$User = 'Tiger\Administrator'
$PHT = @{
  String      = 'Pa$$w0rd'
  AsPlainText = $true
  Force       = $true
}
$PSS     = ConvertTo-SecureString @PHT
$Type    = 'System.Management.Automation.PSCredential'
$CredHVD = New-Object -TypeName $Type -ArgumentList $User,$PSS

# 5. Get Initial Measurements
Measure-VM -VM $VM


# 6. Do some Compute Work in the VM
$SB ={
    1..10000000 | ForEach-Object {$I++;$I--}
}
Invoke-Command -VMName HVDirect -ScriptBlock $SB -Cred $CredHVD

# 7. Get Additional Measurements
Measure-VM -VM $VM