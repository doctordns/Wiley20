gg# 5.1 - Setting Up and Securing your SMB file erver

# Run on FS1

# 1. Add File Server features to FS1
Install-Module -Name WindowsCompatibility -Force
Import-WinModule -Name ServerManager
$Features = 'FileAndStorage-Services','File-Services',
            'FS-FileServer','RSAT-File-Services'
Install-WindowsFeature -Name $Features


# 2. Get SMB Server Settings
Get-SmbServerConfiguration

# 3. Ensure SMB1 is turned off
$CHT = @{
  EnableSMB1Protocol = $false 
  Confirm            = $false
}
Set-SmbServerConfiguration @CHT

# 4. Turn on SMB signing and encryption
$SHT1 = @{
    RequireSecuritySignature = $true
    EnableSecuritySignature  = $true
    EncryptData              = $true
    Confirm                  = $false
}
Set-SmbServerConfiguration @SHT1

# 5. Turn off default server and workstations shares 
$SHT2 = @{
    AutoShareServer       = $false
    AutoShareWorkstation  = $false
    Confirm               = $false
}
Set-SmbServerConfiguration @SHT2

# 6 - turn off server announcements
$SHT3 = @{
    ServerHidden   = $true
    AnnounceServer = $false
    Confirm        = $false
}
Set-SmbServerConfiguration @SHT3

# 7 - restart the service with the new configuration
Restart-Service lanmanserver

# 8. Review SMB Server Configuration 
Get-SmbServerConfiguration

<# undo and set back to defults

Get-SMBShare foo* | remove-SMBShare -Confirm:$False

Set-SmbServerConfiguration -EnableSMB1Protocol $true `
                           -RequireSecuritySignature $false `
                           -EnableSecuritySignature $false `
                           -EncryptData $False `
                           -AutoShareServer $true `
                           -AutoShareWorkstation $false `
                           -ServerHidden $False `
                           -AnnounceServer $True
Restart-Service lanmanserver
#>
