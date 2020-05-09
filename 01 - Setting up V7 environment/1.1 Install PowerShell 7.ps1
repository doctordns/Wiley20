# Chapter 1 - Topic 1 - Install PowerShell 7

# Run on CL1
# Run using an elevated Windows PowerShell 5.1 host

# 1. Install latest versions of Nuget and PowerShellget
Install-PackageProvider Nuget -MinimumVersion 2.8.5.201 -Force |
  Out-Null
Install-Module -Name PowerShellGet -Force -AllowClobber 

# 2. Create local folder C:\Foo
$IT = @{
  ItemType    = 'Directory';
  ErrorAction = 'SilentlyContinue'
}
New-Item -Path C:\Foo @IT | Out-Null
Set-Location C:\Foo


# 3. Download PowerShell 7 installation script
$URI = "https://aka.ms/install-powershell.ps1"
Invoke-RestMethod -Uri $URI | 
  Out-File -FilePath C:\Foo\Install-PowerShell.ps1

# 4. Install PowerShell 7
C:\Foo\Install-PowerShell.ps1 -UseMSI -Quiet -AddExplorerContextMenu -EnablePSRemoting

# 5. Examine the installation folder
Get-Childitem -Path 'C:\Program Files\PowerShell\7' -Recurse |
  Measure-Object -Property length -Sum

# 6. Examine Powershell configuratin JSON file
$Path = "$Env:ProgramFiles\PowerShell\7\powershell.config.json"
Get-Content -Path $Path

# 7. Run PowerShell 7 console and then...
$PSVersionTable

# 8. view Modules folders
$ModFolders = $Env:psmodulepath -split ';'
$I = 0
$ModFolders | 
  ForEach-Object {"$I    $_";$I++}



