$VerbosePreference = 'Continue'
# Sets up the PowerShell 7 environment on a host - PART 1
# Run this in Windows PowerShell 5.1 to bootstrap your way to Powerhell 7.

# 1. Set execution polity and install Nuget and PowerShellGet - Just in case
Write-Verbose 'Setting Execution Policy'
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
Write-Verbose 'Updating Nuget, PowerSHellGet modules'
Install-PackageProvider Nuget -MinimumVersion 2.8.5.201 -Force |
  Out-Null
Install-Module -Name PowerShellGet -Force -AllowClobber 

# 2. Enable CredSSP # We may need it later. 
Enable-WSManCredSSP -DelegateComputer * -Role Client -Force |
  Out-Null
Enable-WSManCredSSP -Role Server -Force  |
  Out-Null
Write-Verbose 'Enabled CredSSP'
  
# 3. Create PowerShell module folders in case they do not exist
Write-Verbose 'Creating module folders'
$IT = @{ItemType = 'Directory';ErrorAction = 'SilentlyContinue'}
New-Item -Path "C:\Program Files\PowerShell\Modules" @IT
New-Item -Path "C:\Users\administrator\Documents\PowerShell\Modules" @IT

# 4. Install PowerShell 7
#    NB: This code installs the latest preview version. Update this at RTM.
Write-Verbose 'Installing PowerShell 7'

New-Item -Path C:\Foo @IT
Set-Location -Path C:\Foo
$URI = "https://aka.ms/install-powershell.ps1"
Invoke-RestMethod -Uri $URI | 
  Out-File -FilePath C:\Foo\Install-PowerShell.ps1
C:\Foo\Install-PowerShell.ps1 -UseMSI -Preview -Quiet

# 5. Save Install-VSCode installation script
Save-Script -Name Install-VSCode -Path C:\Foo

# 6. Now install latest stable system and popular VSCode Extensions
#    NB: this may generate errors, which can generally be ignored
$Extensions =  "Streetsidesoftware.code-spell-checker",
               "yzhang.markdown-all-in-one",
               "davidanson.vscode-markdownlint",
               "vsls-contrib.gistfs"
$InstallHT = @{
  BuildEdition         = 'Stable-System'
  AdditionalExtensions = $Extensions
  LaunchWhenDone       = $true
}             
CD C:\foo
.\Install-VSCode.ps1 @InstallHT



$VerbosePreference = 'SilentlyContinue'