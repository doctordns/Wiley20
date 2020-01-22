# 1.3 - Using the PowerShell Gallery
# 
# Run on CL1 after installing PowerShell 7

# 1. Install Latest Version of Nuget
Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Force 

# 2. Install latest version of PowerShellGet module
Install-Module -Name PackageManagement -Force  

# 3. Get Details of all PS Gallery Modules
$PGSM = Find-Module -Name *
"There are {0:N0} modules in the PS Gallery" -f $PGSM.Count

# 4. Get Details of packages tagges with 'PSEdition_Core'
$PGSMC = Find-Module -Name * -Tag 'PSEdition_Core'
"There are {0:N0} modules supporting PowerSell Core" -f $PGSMC.Count

# 4. Find NTFS Modules
$PGSM | Where-Object Name -match 'NTFS'

# 5. Install the NTFSSecurity Module
Install-Module -Name NTFSSecurity -Force

