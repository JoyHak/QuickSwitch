### Application behavior
QuickSwitch is distributed only through [GitHub](https://github.com/JoyHak/QuickSwitch/releases) and the package managers listed in the [installation section](#installation). The source code and executable files have never been published on forums or other websites. Please keep this in mind when downloading.

QuickSwitch does not have its own update system and does not access multiple files per hour. This includes copying, moving or reading files. It should not increase disk usage or process large amounts of data from the disk. 

QuickSwitch does not stores user data anywhere other than what is visible in the `*.log` files in the directory where the program is installed. QuickSwitch does not send this file over the Internet, and the program developer [@JoyHak](https://github.com/JoyHak) does not have access to logs and errors until they are published by the user.  

The user has the right not to send the collected data and errors, and the user is never required to share data about themselves or their work with QuikSwitch. QuikSwitch is required to work even with errors without interacting with the end user. 

## Verify an archive

After downloading an archive, compare its hash with the digest shown on the matching GitHub Release:

```powershell
(Get-FileHash .\QuickSwitch-1.9.1-x64.zip -Algorithm SHA256).Hash
```

The displayed value must match the release asset digest. Use the `x32` archive only on a 32-bit Windows system.

## Report a problem

Please open a report in the [fork issue tracker](https://github.com/JoyHak/QuickSwitch/issues/new/choose). Remove usernames, machine names, network share names, credentials, and other private paths from logs before attaching them.

## Upstream security context

This repository is a GPL-3.0 fork of [JoyHak/QuickSwitch](https://github.com/JoyHak/QuickSwitch). Security issues affecting the upstream code may also be reported to the upstream project when appropriate; fork-specific fixes should be reported here.
