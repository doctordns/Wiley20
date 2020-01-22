#Function is called at bottom of the script for the scheduled task.
Function Get-PwshUpdates {
    [CmdletBinding()]
    Param (
        [Parameter()]
        [Switch]$Preview
    ) 
    # Define key variables
    $PwshName = "PowerShell 6-x"  # What PowerShell 6 is called
    # Get PowerShell version details
    $Metadata = Invoke-RestMethod https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/metadata.json
    $PwshRelease = $Metadata.ReleaseTag -replace '^v'
    if ($Preview) { 
        $PwshRelease = ($Metadata.PreviewReleaseTag -replace '^v') -replace '-rc'
        $PwshName = $PwshName -replace '-x', '-preview' 
    }
    Write-Verbose "PowerShell version: [$PwshName]"    
    # get current version installed
    $PwshCurrent = Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Where-Object { $_.DisplayName -match "$PwshName" } |
    Select-Object DisplayName, DisplayVersion, UnInstallString
    Write-Verbose "Installed Version uninstall string: [$pwshcurrent]"         
    # create a com object to use for a popup
    $Alert = New-Object -ComObject wscript.shell 
    # Compare and take action
    if ($PwshCurrent) {
        if ($PwshCurrent.DisplayVersion -notlike "$PwshRelease*") {
            $InstallUpdate = $Alert.popup("A new version of $($PwshCurrent.DisplayName) is available!! Update now?", 0, "PowershellCore Update", 32 + 4)
        }
        else {
            Write-Output "$($PwshCurrent.DisplayName) : No Update needed, returning."
            return
        }
    }

    # here need to check if preview existgs
    
    # here we do need to update 
    #using https://github.com/PowerShell/PowerShell/blob/master/tools/install-powershell.ps1
    if ($InstallUpdate -eq 6) {
        $Alert.popup("First the old version will be uninstalled. Please confirm in next window. After that the new download will start, this might take a while", 0, "You selected yes", 32)
        try {
            Start-Process -FilePath cmd.exe -ArgumentList '/c', ($PwshCurrent.UninstallString) -NoNewWindow -Wait
            if ($Preview) {
                Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI -Preview" -ErrorAction Stop
            }
            Else {
                Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI" -ErrorAction Stop 
            }
        }
        catch {
            $Errormessage = $_
            $Alert.popup("Update has failed. $Errormessage", 0, "ALERT", 48)

        }

    }
    Else {
        Write-Output "Update canceled by user."
    }
}

Get-PwshUpdates
Get-PwshUpdates -Preview