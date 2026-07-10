function Open-BitLocker {
    <#
.SYNOPSIS
    Opens Bit Locker.

.DESCRIPTION
    Opens Bit Locker.

.EXAMPLE
    Open-BitLocker
    Runs Open-BitLocker.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-BitLocker
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-BitLocker')]
    [Alias('BitLocker')]
    param()
    control.exe /name Microsoft.BitLockerDriveEncryption
}
