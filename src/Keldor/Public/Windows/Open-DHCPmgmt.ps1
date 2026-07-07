function Open-DHCPmgmt {
<#
.SYNOPSIS
    Opens DHC Pmgmt.

.DESCRIPTION
    Opens DHC Pmgmt.

.EXAMPLE
    Open-DHCPmgmt
    Runs Open-DHCPmgmt.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-DHCPmgmt
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-DHCPmgmt')]
    [Alias('dhcp')]
    param()
    try {
        $ErrorActionPreference = "Stop"
        dhcpmgmt.msc
    }
    catch {
        Write-Output "Active Directory snapins are not installed/enabled."
    }
}
