# Initial Profile File for PowerShell Host

"In Customisations for [$($Host.Name)]"
"On $(hostname)"

# Set Format enum limit
$FormatEnumerationLimit = 99

# Set some command Dgit pushefaults
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
"`$Credrk created for $($credrk.username)"

Write-Host "Completed Customisations to $(hostname)"