# Chapter 1 - Topic 1 - Install PowerShell 7

# Run on CL1
# Run using an elevated Windows PowerShell 5.1 host

# 1. Create local folders and Set-Location to C:\Foo
$IT = @{
  ItemType = 'Directory';
  ErrorAction = 'SilentlyContinue'
}
New-Item -Path C:\Foo @IT |
  Out-Null
New-Item -Path 'C:\Program Files\PowerShell\Modules' @IT |
  Out-Null
$Path = 'C:\Users\Administrator\Documents\PowerShell\Modules'
New-Item -Path $Path @IT 
Set-Location -Path C:\Foo

# 2. Download PowerShell 7 installation script
$URI = "https://aka.ms/install-powershell.ps1"
Invoke-RestMethod -Uri $URI | 
  Out-File -FilePath C:\Foo\Install-PowerShell.ps1

# 3. Just in case, set Executionn Policy to unrestricted
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

# 4. Install PowerShell 7
C:\Foo\Install-PowerShell.ps1 -UseMSI -Quiet -AddExplorerContextMenu -EnablePSRemoting |
  Out-Null
