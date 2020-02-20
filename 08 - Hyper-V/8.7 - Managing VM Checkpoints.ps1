# 8.7 - Managing VM Checkpoints

# Run on HV1 after creatign HVDiret VM

# 1. Create credentials for HVDirect VM
$RKUN   = 'Reskit\Administrator'
$PS     = 'Pa$$w0rd'
$RKP    = ConvertTo-SecureString -String $PS -AsPlainText -Force
$T      = 'System.Management.Automation.PSCredential'
$RKCred = New-Object -TypeName $T -ArgumentList $RKUN,$RKP

# 2. Look at C:\ in HVDirect before startiung
$VMName = 'HVDirect'
$ICHT = @{
  VMName      = $VMName
  ScriptBlock = {Get-ChildItem -Path C:\ | Format-Table}
  Credential  = $RKCred
}
Invoke-Command @ICHT

# 3. Create a Checkpoint of HVDirect
$CPHT = @{
  VMName       = $VMName
  SnapshotName = 'Checkpoint1'
}
Checkpoint-VM @CPHT

# 4. Look at the files created to support checkpoints
$Parent = Split-Path -Parent (Get-VM -Name $VMName |
            Select-Object -ExpandProperty HardDrives).Path |
              Select-Object -First 1
Get-ChildItem -Path $Parent

# 5. Create some content in a file on HVDIrect and display it
$SB = {
   $FileName1 = 'C:\File_After_Checkpoint_1'
   'After Checkpoint 1' | 
     Out-File -FilePath $FileName1
   Get-Content -Path $FileName1
}
$ICHT = @{
  VMName      = $VMName
  ScriptBlock = $SB
  Credential  = $RKCred
}
Invoke-Command @ICHT

# 6. Take a second checkpoint
$SNHT = @{
  VMName        = $VMName
#  ComputerName  = 'HV1'  
  SnapshotName  = 'Checkpoint2'
}
Checkpoint-VM @SNHT

# 7. Get the VM checkpoint details for HVDirect
Get-VMCheckPoint -VMName $VMName

# 8. Look at the files supporting the two checkpoints
Get-ChildItem -Path $Parent

# 9. Create and display another file in HVDirect
#    (after you have taken Chgeckpoint2)
$SB = {
  $FileName2 = 'C:\File_After_Checkpoint_2'
  'After Checkpoint 2' | 
    Out-File -FilePath $FileName2
  Get-ChildItem -Path C:\ -File | Format-Table
}
$ICHT = @{
  VMName      = $VMName
  ScriptBlock = $SB 
  Credential  = $RKCred

}
Invoke-Command @ICHT

# 10. Restore the VM back to the checkpoint named Checkpoin1
$CP1 = Get-VMCheckpoint -VMName $VMName -Name Checkpoint1
Restore-VMCheckpoint -VMSnapshot $CP1 -Confirm:$false
Start-VM -Name $VMName
Wait-VM -For IPAddress -Name $VMName

# 11. See what files we have now in the VM
$ICHT = @{
  VMName      = $VMName
  ScriptBlock = {Get-ChildItem -Path C:\ |
                   Format-Table }
  Credential  = $RKCred
}
Invoke-Command @ICHT

# 12. Roll forward to Checkpoint2
$Checkpoint2 = Get-VMCheckpoint -VMName $VMName -Name Checkpoint2
Restore-VMCheckpoint -VMSnapshot $Checkpoint2 -Confirm:$false
Start-VM -Name $VMName
Wait-VM -For IPAddress -Name $VMName

# 13. Observe the files you now have on HVDirect VM
$ICHT = @{
  VMName      = $VMName
  ScriptBlock = {Get-ChildItem -Path C:\ | 
                   Format-Table }
  Credential  = $RKCred
}
Invoke-Command @ICHT

# 14. View Checkpoints for HVDirect
Get-VMCheckpoint -VMName $VMName

# 15. View VM Data Files
Get-ChildItem -Path $Parent

# 16. Remove all the checkpints for HVDirect
Get-VMCheckpoint -VMName $VMName |
  Remove-VMSnapshot

# 17. Check VM data files again
Get-ChildItem -Path $Parent