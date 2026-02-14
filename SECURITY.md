> [!caution]
>Please read this information very carefully. It will help you determine whether the version of QuickSwitch you downloaded is safe.

### Application behavior
QuickSwitch is distributed only through [GitHub](https://github.com/JoyHak/QuickSwitch/releases) and the package managers listed in the [installation section](#installation). The source code and executable files have never been published on forums or other websites. Please keep this in mind when downloading.

QuickSwitch does not have its own update system and does not access multiple files per hour. This includes copying, moving or reading files. It should not increase disk usage or process large amounts of data from the disk. 

QuickSwitch does not stores user data anywhere other than what is visible in the `*.log` files in the directory where the program is installed. QuickSwitch does not send this file over the Internet, and the program developer [@JoyHak](https://github.com/JoyHak) does not have access to logs and errors until they are published by the user.  

The user has the right not to send the collected data and errors, and the user is never required to share data about themselves or their work with QuikSwitch. QuikSwitch is required to work even with errors without interacting with the end user. 

### Security verification

You can verify that the downloaded file was compiled by me and has not been altered by anyone else.

See [detailed guide here](https://github.com/JoyHak/chocolatey/blob/main/QuickSwitch/tools/VERIFICATION.md).If you have Chocolatey, you can [download verification script](https://github.com/JoyHak/chocolatey/blob/main/QuickSwitch/tools/verifysignature.ps1). The software can be verified manually by doing the following:
1.   Verify sha256 checksums with GitHub (you can also find them on [release page](https://api.github.com/repos/JoyHak/QuickSwitch/releases/latest)):
      ```powershell
     (Get-FileHash QuickSwitch-1.8-x64.zip sha256).hash -eq ($asset.digest -replace "sha256:").ToUpper()
     ```
     > If you have 32-bit system/CPU, replace `x64` with `x32`.
2.   Verify zip signature using utility `ZipSign.exe`:
     1.   Download and install: <https://github.com/falk-werner/zipsign>
     2.   Download [secutiry certificate](https://github.com/JoyHak/chocolatey/blob/main/QuickSwitch/tools/certificate.pem) and verify that zip contains it:
     ```powershell
     zipsign verify --verbose --file QuickSwitch-1.8-x64.zip --certificate certificate.pem
     ```
     3.   Get certificate info:
     ```powershell
     zipsign info --file QuickSwitch-1.8-x64.zip
     ```    
     4.   For both 32-bit and 64-bit software certificate info must contain the following:
          -   issuer: C=EN, ST=Alabama, L=Montgomery, O=ToYu studio, CN=Rafaello/emailAddress=Discord: @toyu.s
          -   serialNumber: 0x64E7BEECFF4CB5E7CD185304927A849FD5959F0D
3. Verify the date and time of compilation:
     1. Get date and time of the digital signature:
     ```powershell
     $signature = Get-AuthenticodeSignature QuickSwitch.exe
     $signatureDate = [DateTime]$signature.SignerCertificate.NotBefore.ToUniversalTime()
     ```
     2. Get date and time of last modification by me on GitHub: 
     ```powershell
     $release  =  Invoke-RestMethod "https://api.github.com/repos/JoyHak/QuickSwitch/releases/latest"
     $asset    = $release.assets | where { $_.name -match "x64" }
     $assetDate = [DateTime]$asset.updated_at.ToUniversalTime()
     ```
     3. Ensure that the date of the digital signature is earlier than the date of the last modification:
     ```powershell
     [DateTime]::Compare($assetDate, $signatureDate) -ge 0
     ```
     > If there is no digital signature or its date is later than the date of the change, someone has recompiled the executable after my publication!
