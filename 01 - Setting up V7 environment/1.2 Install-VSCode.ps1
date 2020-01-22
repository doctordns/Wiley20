# 1.2 Install-VSCode
# 
# Run on CL1 after installing PowerShell 7
# Run in PowerShell 7 WIndow!

# 1. Download the VS Code Installation Script
$VSCPATH = 'C:\Foo'
Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Force
Save-Script -Name Install-VSCode -Path $VSCPATH
Set-Location -Path $VSCPATH

# 2. Now run it and add in some popular VSCode Extensions
$Extensions =  "Streetsidesoftware.code-spell-checker",
               "yzhang.markdown-all-in-one",
               "Powershell"
$InstallHT = @{
  BuildEdition         = 'Stable-System'
  AdditionalExtensions = $Extensions
  LaunchWhenDOne       = $true
}             
.\Install-VSCode.ps1 @InstallHT 

#  At this point, VS Code should be displayed.
#  The remainder of this script in VS Code (or PowerSHell 7 console)

# 3. Create a Sample Profile File
$SAMPLE = "https://raw.githubusercontent.com/doctordns/Wiley20/master" + 
          "/Microsoft.VSCode_profile.ps1"
(Invoke-WebRequest -Uri $Sample).Content |
  Out-File $Profile

# 4. Create Default Powershell Module Folders
$IT = @{
  ItemType    = 'Directory'
  ErrorAction = 'SilentlyContinue'
}
New-Item -Path 'C:\Program Files\PowerShell\Modules' @IT
New-Item -Path 'C:\Users\administrator\Documents\PowerShell\Modules' @IT
  
# 5. Download Cascadia Code font from GitHub
# Get File Locations
$CascadiaFont    = 'Cascadia.ttf'    # font name
$CascadiaRelURL  = 'https://github.com/microsoft/cascadia-code/releases'
$CascadiaRelease = Invoke-WebRequest -Uri $CascadiaRelURL # Get all of them
$CascadiaPath    = "https://github.com" + ($CascadiaRelease.Links.href | 
                      Where-Object { $_ -match "($cascadiaFont)" } | 
                        Select-Object -First 1)
$CascadiaFile   = "C:\Foo\$CascadiaFont"
# Download Cascadia Code font file
Invoke-WebRequest -Uri $CascadiaPath -OutFile $CascadiaFile
# Install Cascadia Code font
$FontShellApp = New-Object -Com Shell.Application
$FontShellNamespace = $FontShellApp.Namespace(0x14)
$FontShellNamespace.CopyHere($cascadiaFile, 0x10)

# 7. Update Local User Settings for VS Code
#    This step in particular needs to be run in PowerShell 7!
$JSON = @'
{
  "workbench.colorTheme": "Quiet Light",
  "powershell.codeFormatting.useCorrectCasing": true,
  "files.autoSave": "onWindowChange",
  "files.defaultLanguage": "powershell",
  "editor.fontFamily": "'Cascadia Code',Consolas,'Courier New'",
  "workbench.editor.highlightModifiedTabs": true,
  "window.zoomLevel": 1
}
'@
$JHT = ConvertFrom-Json -InputObject $JSON -AsHashtable
$PWSH = "C:\\Program Files\\PowerShell\\7-preview\\pwsh.exe"
$JHT += @{
  "terminal.integrated.shell.windows" = "$PWSH"
}
$Path = $Env:APPDATA
$CP   = '\Code\User\Settings.json'
$Settings = Join-Path  $Path -ChildPath $CP
$JHT |
  ConvertTo-Json  |
    Out-File -FilePath $Settings
