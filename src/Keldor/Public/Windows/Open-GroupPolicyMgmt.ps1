function Open-GroupPolicyMgmt {
<#
.SYNOPSIS
    Opens Group Policy Mgmt.

.DESCRIPTION
    Opens Group Policy Mgmt.

.EXAMPLE
    Open-GroupPolicyMgmt
    Runs Open-GroupPolicyMgmt.

.OUTPUTS
    System.Object

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 08/19/2017 22:30:09
    LASTEDIT: 2022-09-04 12:12:07
    KEYWORDS:

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-GroupPolicyMgmt
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-GroupPolicyMgmt')]
    [Alias('gpo','gpmc','GroupPolicy')]
    param()
    try {
        $ErrorActionPreference = "Stop"
        gpmc.msc
    }
    catch {
        Write-Output "Active Directory snapins are not installed/enabled."
    }
}
