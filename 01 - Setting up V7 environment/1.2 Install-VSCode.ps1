# 1.2 Install-VSCode
# 
# Run on CL1 after installing PowerShell
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

# 3. Create a Sample Profile File
$SAMPLE = "https://raw.githubusercontent.com/doctordns/Wiley20/master" + 
          "/Microsoft.VSCode_profile.ps1"
(Invoke-WebRequest -Uri $Sample).Content |
  Out-File $Profile

# 4. Create Powershell Module Folders
$IT = @{
  ItemType    = 'Directory'
  ErrorAction = 'SilentlyContinue'
}
New-Item -Path 'C:\Program Files\PowerShell\Modules' @IT
New-Item -Path 'C:\Users\administrator\Documents\PowerShell\Modules' @IT
  
# 5. Download Cascadia Code font from GitHub
$DLPath = 'https://github.com/microsoft/cascadia-code/releases/'+
          'download/v1911.20/Cascadia.ttf'
$DLFile = 'C:\Foo\Cascadia.TTF'
Invoke-WebRequest -Uri $DLPath -OutFile $DLFile

# 6. Install the font using Shell.Application COM object
$Destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
$Destination.CopyHere($DLFile,0x10)

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


# Now Exit PowerSheLL 5.X and continue with VS Code.

