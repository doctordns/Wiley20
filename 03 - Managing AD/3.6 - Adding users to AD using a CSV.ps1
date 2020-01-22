# 3.6 - Adding Users to Active Directory using a CSV File

# Run On DC1

# 1. Create CSV
$CSVDATA = @'
Firstname, Initials, Lastname, UserPrincipalName, Alias, Description, Password
S,K,Masterly, SKM, Sylvester, Data Team, Christmas42
C,B, Smith, CBS, Claire, Receptionist, Christmas42
Billy, Bob, JoeBob, BBJB, BillyBob, A Bob, Christmas42
Malcolm, Dudley, Duelittle, Malcolm, Malcolm, Mr Danger, Christmas42
'@
$CSVDATA | Out-File -FilePath C:\Foo\Users.Csv

# 2. Import a CSV file containing the details of the users you 
#    want to add to AD:
$Users = Import-CSV -Path C:\Foo\Users.Csv | 
  Sort-Object  -Property Alias
$Users | Sort-Object -Property Alias | Format-Table

# 3. Add the users using the CSV
$Users | 
  ForEach  -Parallel {
    $User = $_ 
    #  Create a hash table of properties to set on created user
    $Prop = @{}
    #  Fill in values
    $Prop.GivenName         = $User.Firstname
    $Prop.Initials          = $User.Initials
    $Prop.Surname           = $User.Lastname
    $Prop.UserPrincipalName = $User.UserPrincipalName + "@Reskit.Org"
    $Prop.Displayname       = $User.FirstName.Trim() + " " +
                              $User.LastName.Trim()
    $Prop.Description       = $User.Description
    $Prop.Name              = $User.Alias
    $PW = ConvertTo-SecureString -AsPlainText $User.Password -Force
    $Prop.AccountPassword   = $PW
    $Prop.ChangePasswordAtLogon = $true
    $Prop.Path                  = 'OU=IT,DC=Reskit,DC=ORG'
    $Prop.Enabled               = $true
    #  Now Create the User
    New-ADUser @Prop
    # Finally, Display User Created
    "Created $($Prop.Name)"
}

# 4. Show All Users in AD (Reskit.Org)
Get-Aduser -Filter * | 
  Format-Table -Property Name, UserPrincipalName


### Remove the users created in the script

$users = Import-Csv C:\foo\users.csv
foreach ($User in $Users)
{
  Get-ADUser -Identity $user.alias | Remove-AdUser



}
