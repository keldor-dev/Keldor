function Open-SoftwareCenter {
    <#
.SYNOPSIS
    Opens Software Center.

.DESCRIPTION
    Opens Software Center.

.PARAMETER Page
    Specifies the Page value.

.EXAMPLE
    Open-SoftwareCenter
    Runs Open-SoftwareCenter.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-SoftwareCenter
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-SoftwareCenter')]
    [Alias('SoftwareCenter', 'SCCM', 'MECM')]
    param(
        [Parameter(
            Mandatory = $false
        )]
        [ValidateSet('AvailableSoftware', 'Updates', 'OSD', 'InstallationStatus', 'Compliance', 'Options')]
        [ValidateNotNullOrEmpty()]
        [Alias('Tab')]
        [string]$Page = "AvailableSoftware"
    )

    Start-Process softwarecenter:Page=$Page
}
