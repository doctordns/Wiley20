# x.x  Install Cascadia Code

# 1. Download Cascadia Code font from GitHub
$DLPath = 'https://github.com/microsoft/cascadia-code/releases/'+
          'download/v1911.20/Cascadia.ttf'
$DLFile = 'C:\Foo\Cascadia.TTF'
Invoke-WebRequest -Uri $DLPath -OutFile $DLFile

# 2. Install it way 1
$Font = New-Object -Com Shell.Application
$Destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
$Destination.CopyHere($DLFile,0x10)

