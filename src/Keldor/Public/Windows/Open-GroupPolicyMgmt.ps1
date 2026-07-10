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

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-GroupPolicyMgmt
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-GroupPolicyMgmt')]
    [Alias('gpo', 'gpmc', 'GroupPolicy')]
    param()
    try {
        $ErrorActionPreference = "Stop"
        gpmc.msc
    } catch {
        Write-Output "Active Directory snapins are not installed/enabled."
    }
}
