# 1.4 - Creating an Internal PowerShell Repository
# 
# Run from Cl1 - run in an elevated session
# Uses self signed Certificates

# 1. Set Execution Policy to Remote Signed
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope Process 
Set-ExecutionPolicy -ExecutionPolicy AllSigned -Scope LocalMachine
$WarningPreference = 'SilentlyContinue' # to avoid p.6 warnings

# 2.Create a self-signed certificate
Import-Module PKI
$CERTHT = @{
  Subject           = 'Sign.Reskit.Org'
  Type              = "CodeSigningCert"
  CertStoreLocation = "Cert:\CurrentUser\my"
}
$SignCert = New-SelfSignedCertificate @CERTHT

# 3. View Certificate
$SignCert

# 3. Create a simple .PS1 Filee
$File = @"
# A script to be signed
"Hello World"
"@
$SignedFile = "C:\Foo\HelloWorld.ps1"
$File | 
  Out-File -FilePath $SignedFile -Force

# 4. Attempt to Run the File (pre-signing)
& $SignedFile

# 5. Sign the script with the $SignCert certificate
Set-AuthenticodeSignature -FilePath $SignedFile -Certificate $SignCert |
    Format-Table -AutoSize -Wrap
Get-Content -Path $SignedFile |
  Select-Object -First 10  

# 6. Copy the cert to the Trusted Root Store
$CertStore = 'System.Security.Cryptography.X509Certificates.X509Store'
$CertArgs  = 'Root','LocalMachine'
$Store     = New-Object -TypeName $CertStore` -ArgumentList $CertArgs
$Store.Open(‘ReadWrite’)
$Store.Add($SignCert)
$Store.Close()    

# 7. Sign the script
$SignCert = Get-ChildItem -Path Cert:\CurrentUser\my -CodeSigningCert
Set-AuthenticodeSignature -FilePath $SignedFile -Certificate $SignCert |
    Format-Table -AutoSize -Wrap

# 8. Run the code
& $SignedFile
