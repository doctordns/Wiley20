# Initial Profile File for PowerShell Host

# Write Details
Write-Host "In Customisations for [$($Host.Name)]"
Write-Host "On $(hostname)"

# Set $Me
$ME = whoami
Write-Host "Logged on as $ME"

# Set Format enum limit
$FormatEnumerationLimit = 99

# Set some command defaults
$PSDefaultParameterValues = @{
  "*:autosize"       = $true
  'Receive-Job:keep' = $true
  '*:Wrap'           = $true
}

# Set home to C:\Foo for ~, then go there
New-Item C:\Foo -ItemType Directory -Force -EA 0 | out-null
$Provider = Get-PSProvider FileSystem
$Provider.Home = 'C:\Foo'
Set-Location -Path ~
Write-Host 'Setting home to C:\Foo'

# Add a new function Get-HelpDetailed and set an alias
Function Get-HelpDetailed { 
    Get-Help $args[0] -Detailed
} # END Get-HelpDetailed Function

# Set aliases
Set-Alias gh    Get-Help
Set-Alias ghd   Get-HelpDetailed

# Reskit Credential
$Urk = 'Reskit\Administrator'
$Prk = ConvertTo-SecureString 'Pa$$w0rd' -AsPlainText -Force
$Credrk = [pscredential]::New($Urk, $Prk)
Write-Host "`$Credrk created for $($Credrk.username)"

Write-Host "Completed Customisations to $(hostname)"