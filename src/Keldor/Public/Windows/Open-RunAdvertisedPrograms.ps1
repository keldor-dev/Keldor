function Open-RunAdvertisedPrograms {
    <#
.SYNOPSIS
    Opens Run Advertised Programs.

.DESCRIPTION
    Opens Run Advertised Programs.

.EXAMPLE
    Open-RunAdvertisedPrograms
    Runs Open-RunAdvertisedPrograms.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-RunAdvertisedPrograms
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-RunAdvertisedPrograms')]
    [Alias('rap')]
    param()
    if (Test-Path "C:\Windows\SysWOW64\CCM\SMSRAP.cpl") { Start-Process C:\Windows\SysWOW64\CCM\SMSRAP.cpl }
    elseif (Test-Path "C:\Windows\System32\CCM\SMSRAP.cpl") { Start-Process C:\Windows\System32\CCM\SMSRAP.cpl }
    else { throw "Run Advertised Programs not found" }
}
