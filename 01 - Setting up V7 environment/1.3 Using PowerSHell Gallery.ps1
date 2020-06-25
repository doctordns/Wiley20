# 1.3 - Using the PowerShell Gallery
# 
# Run on DC1  after installing PowerShell 7 and VS Code

# 1. Get Details of all PS Gallery Modules
$PGSM = Find-Module -Name *
"There are {0:N0} modules in the PS Gallery" -f $PGSM.Count

# 2. Get Details of packages tagged with 'PSEdition_Core'
$PGSMC = Find-Module -Name * -Tag 'PSEdition_Core'
"There are {0:N0} modules supporting PowerShell Core" -f $PGSMC.Count

# 3. Find NTFS Modules
$PGSM | Where-Object Name -match 'NTFS'

# 4. Install the NTFSSecurity Module
Install-Module -Name NTFSSecurity -Force

# 5. View Commands in the NTFS Security module
Get-Command -Module NTFSSecurity

