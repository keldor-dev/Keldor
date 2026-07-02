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

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 08/19/2017 22:25:18
    LASTEDIT: 2022-09-04 12:09:18
    KEYWORDS:

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
