+# Setup-VSCodeEvironment.ps1
# (c) 2020 Thomas Lee (DoctorDNS@Gmail.Com)

# This Gist adds the Concordia Code font to Windows and configures VS Code

# This script is part of Thomas Lee's PowerShell 7 book published by Wiley
# If you are are seeking to reproduce the environment for PowerShell 7 to follow the book's contents,
# Run this script in VS Code, using PowerShell 7. Run this after you install each VM and after you have installed PowerShell 7.

# NB: This Gist uses PowerShell 7 features so you must run it either in VS COde or theConsole after
#     you install PowerShell 7/


# 1. Download Cascadia Code font from GitHub
$CascadiaFont    = 'Cascadia.ttf'    # font name
$CascadiaFontPL  = 'CascadiaPL.ttf'  # PL version
$CascadiaRelURL  = 'https://github.com/microsoft/cascadia-code/releases'
$CascadiaRelease = Invoke-WebRequest -Uri $CascadiaRelURL # Get all of them
$CascadiaPath    = "https://github.com" + ($CascadiaRelease.Links.href | 
                      Where-Object { $_ -match "($cascadiaFont)" } | 
                        Select-Object -First 1)
$CascadiaPathPL = "https://github.com" + ($CascadiaRelease.Links.href | 
                     Where-Object { $_ -match "($cascadiaFontPL)" } | 
                       Select-Object -First 1)
$CascadiaFile   = "C:\Foo\$CascadiaFont"
$CascadiaFilePL = "C:\Foo\$CascadiaFontPL"
# Download Cascadia Code font file
Invoke-WebRequest -Uri $CascadiaPath -OutFile $CascadiaFile
# Download Cascadia Code PL Font File
Invoke-WebRequest -Uri $CascadiaPathPL -OutFile $CascadiaFilePL
# Install Cascadia Code
$FontShellApp = New-Object -Com Shell.Application
$FontShellNamespace = $FontShellApp.Namespace(0x14)
$FontShellNamespace.CopyHere($cascadiaFile, 0x10)
$FontShellNamespace.CopyHere($cascadiaFilePL, 0x10)

# 2. Install the font using Shell.Application COM object
$Destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
$Destination.CopyHere($DLFile,0x10)

# 3. Create a short cut to VSCode
$SourceFileLocation  = "$env:ProgramFiles\Microsoft VS Code\Code.exe"
$ShortcutLocation    = "C:\foo\vscode.lnk"
# Create a  new wscript.shell object
$WScriptShell        = New-Object -ComObject WScript.Shell
$Shortcut            = $WScriptShell.CreateShortcut($ShortcutLocation)
$Shortcut.TargetPath = $SourceFileLocation
#Save the Shortcut to the TargetPath
$Shortcut.Save()

# 4. Create a short cut to PowerShell 7
$SourceFileLocation  = "$env:ProgramFiles\PowerShell\7-Preview\pwsh.exe"
$ShortcutLocation    = 'C:\Foo\pwsh.lnk'
# Create a  new wscript.shell object
$WScriptShell        = New-Object -ComObject WScript.Shell
$Shortcut            = $WScriptShell.CreateShortcut($ShortcutLocation)
$Shortcut.TargetPath = $SourceFileLocation
#Save the Shortcut to the TargetPath
$Shortcut.Save()

$XML = @'
<Activity
    x:Class="Microsoft.PowerShell.DynamicActivities.Activity_542011301"
    xmlns="http://schemas.microsoft.com/netfx/2009/xaml/activities"
    xmlns:sad="clr-namespace:System.Activities.Debugger;assembly=System.Activities"
    xmlns:local="clr-namespace:Microsoft.PowerShell.DynamicActivities"
    xmlns:mva="clr-namespace:Microsoft.VisualBasic.Activities;assembly=System.Activities"
    mva:VisualBasic.Settings="Assembly references and imported namespaces serialized as XML namespaces"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    xmlns:ns0="clr-namespace:System;assembly=mscorlib"
    xmlns:ns1="clr-namespace:Microsoft.PowerShell.Utility.Activities;assembly=Microsoft.PowerShell.Utility.Activities"
    xmlns:ns2="clr-namespace:Microsoft.PowerShell.Activities;assembly=Microsoft.PowerShell.Activities"
    xmlns:ns3="clr-namespace:System.Activities;assembly=System.Activities"
    xmlns:ns4="clr-namespace:System.Management.Automation;assembly=System.Management.Automation"
    >
    <Sequence>
        <ns2:SetPSWorkflowData>
            <ns2:SetPSWorkflowData.OtherVariableName>Position</ns2:SetPSWorkflowData.OtherVariableName>
            <ns2:SetPSWorkflowData.Value>
                <ns3:InArgument x:TypeArguments="ns0:Object">
                    <ns2:PowerShellValue x:TypeArguments="ns0:Object" Expression="'2:1:wf1'" />
                </ns3:InArgument>
            </ns2:SetPSWorkflowData.Value>
        </ns2:SetPSWorkflowData>
        <ns1:WriteOutput>
            <ns1:WriteOutput.NoEnumerate>[System.Management.Automation.SwitchParameter.Present]</ns1:WriteOutput.NoEnumerate>
            <ns1:WriteOutput.InputObject>
                <InArgument x:TypeArguments="ns4:PSObject[]">
                    <ns2:PowerShellValue x:TypeArguments="ns4:PSObject[]" Expression="&quot;Have a nice day&quot;" />
                </InArgument>
            </ns1:WriteOutput.InputObject>
        </ns1:WriteOutput>
        <Sequence.Variables>
            <Variable Name="WorkflowCommandName" x:TypeArguments="ns0:String" Default = "wf1" />
        </Sequence.Variables>
    </Sequence>
</Activity>
'@
$XML | out-file -FilePath c:\foo\foo.


# 5. Import a startlayut.XML file
Import-StartLayout -LayoutPath C:\foo\layout.xml -MountPath c:\

# 4. Update Local User Settings for VS Code
#    This step in particular needs to be run in PowerShell 7!
$JSON = @'
{
  "editor.fontFamily": "'Cascadia Code',Consolas,'Courier New'",
  "editor.tabCompletion": "on",
  "files.autoSave": "onWindowChange",
  "files.defaultLanguage": "powershell",
  "powershell.codeFormatting.useCorrectCasing": true,
  "window.zoomLevel": 1,
  "workbench.editor.highlightModifiedTabs": true,
  "workbench.colorTheme": "Quiet Light",
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