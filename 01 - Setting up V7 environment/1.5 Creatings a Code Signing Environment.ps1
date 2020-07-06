# 1.5. Creating a Code Signing environment
# 
# Run from DC1 - run in an elevated session
# Uses self signed Certificates


# 1. Create a self-signed certificate
Import-Module PKI -WarningAction SilentlyContinue
$CERTHT = @{
  Subject           = 'Sign.Reskit.Org'
  Type              = "CodeSigningCert"
  CertStoreLocation = "Cert:\CurrentUser\my"
}
$SignCert = New-SelfSignedCertificate @CERTHT

# 2. View Certificate
$SignCert

# 3. Create a simple .PS1 File
$File = @"
# A script to be signed
"Hello World"
"@
$SignedFile = "C:\Foo\HelloWorld.ps1"
$File | 
  Out-File -FilePath $SignedFile -Force

# 4. Set Execution Policy to All Signed
Set-ExecutionPolicy -ExecutionPolicy AllSigned 

# 5. Attempt to Run the File (pre-signing)
& $SignedFile

# 6. Sign the script with the $SignCert certificate
Set-AuthenticodeSignature -FilePath $SignedFile -Certificate $SignCert 

# 7. Copy the cert to the Trusted Root Cert store of Local Machine
#    And to the Trusted Publisher cert store
# Local Machine Trusted Root store
$CertStore = 'System.Security.Cryptography.X509Certificates.X509Store'
$CertArgs  = 'Root','LocalMachine'
$Store     = New-Object -TypeName $CertStore -ArgumentList $CertArgs
$Store.Open('ReadWrite')
$Store.Add($SignCert)
$Store.Close()    
# Local Machine Trusted Publisher store
$CertStore = 'System.Security.Cryptography.X509Certificates.X509Store'
$CertArgs  = 'TrustedPublisher','LocalMachine'
$Store     = New-Object -TypeName $CertStore -ArgumentList $CertArgs
$Store.Open('ReadWrite')
$Store.Add($SignCert)
$Store.Close()    

# 8. Re-Sign the script
$SignCert = Get-ChildItem -Path Cert:\CurrentUser\my -CodeSigningCert
Set-AuthenticodeSignature -FilePath $SignedFile -Certificate $SignCert |
    Format-Table -AutoSize -Wrap

# 9. Run the script
& $SignedFile

# 10. Test the script’s digital signature
Get-AuthenticodeSignature -FilePath $SignedFile |
  Format-Table -AutoSize


