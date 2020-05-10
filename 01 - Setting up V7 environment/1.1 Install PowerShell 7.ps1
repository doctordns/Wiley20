# Chapter 1 - Topic 1 - Install PowerShell 7

# Run on CL1
# Run using an elevated Windows PowerShell 5.1 host

# 1. Enable scripts to be run
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

# 2. Install latest versions of Nuget and PowerShellget
Install-PackageProvider Nuget -MinimumVersion 2.8.5.201 -Force |
  Out-Null
Install-Module -Name PowerShellGet -Force -AllowClobber 

# 3. Create local folder C:\Foo
$LFHT = @{
  ItemType    = 'Directory';
  ErrorAction = 'SilentlyContinue' # should it already exist
}
New-Item -Path C:\Foo @LFHT | Out-Null

# 4. Download PowerShell 7 installation script
Set-Location C:\Foo
$URI = "https://aka.ms/install-powershell.ps1"
Invoke-RestMethod -Uri $URI | 
  Out-File -FilePath C:\Foo\Install-PowerShell.ps1

# 5. View Installation Script Help
Get-Help -Name C:\Foo\Install-PowerShell.ps1

# 6. Install PowerShell 7
$EXTHT = @{
  UseMSI                 = $true
  Quiet                  = $true 
  AddExplorerContextMenu = $true
  EnablePSRemoting       = $true
}
C:\Foo\Install-PowerShell.ps1 @EXTHT


# 7. Examine the installation folder
Get-Childitem -Path $env:ProgramFiles\PowerShell\7 -Recurse |
  Measure-Object -Property Length -Sum

# 8. Examine Powershell configuratin JSON file
$Path = "$Env:ProgramFiles\PowerShell\7\powershell.config.json"
Get-Content -Path $Path

# 9. View Module folders
#  View module folders for autoload
$I = 0
$env:PSModulePath -split ';' |
  Foreach-Object {
    "[{0:N0}]   {1}" -f $I++, $_
  }

# 10. View Profile File locations
# Inside ISE
$profile | Format-List -Property *host* -Force
# from WIndows PowerShell Console
powershell -command '$Profile| format-list -force -property *host*'


# Run remainder in Powershell 7 console. 



# 11. Run PowerShell 7 console and then...
$PSVersionTable

# 12. View Modules folders
$ModFolders = $Env:psmodulepath -split ';'
$I = 0
$ModFolders | 
  ForEach-Object {"[{0:N0}]   {1}" -f $I++, $_}

# 13 View Profile Locations
$PROFILE | Format-List -Property *Host* -Force

# 14 Create  Current user/Current host profile
$URI = 'https://raw.githubusercontent.com/doctordns/Wiley20/master/' +
       'Goodies/Microsoft.PowerShell_Profile.ps1'
$ProfileFile = $Profile.CurrentUserCurrentHost
New-Item $ProfileFile -Force -WarningAction SilentlyContinue |
   Out-Null

# 15. Download Sample
(Invoke-WebRequest -Uri $uri -UseBasicParsing).Content | 
  Out-File -FilePath  $ProfileFile

