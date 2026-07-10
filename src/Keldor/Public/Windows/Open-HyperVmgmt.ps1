function Open-HyperVmgmt {
    <#
.SYNOPSIS
    Opens Hyper Vmgmt.

.DESCRIPTION
    Opens Hyper Vmgmt.

.EXAMPLE
    Open-HyperVmgmt
    Runs Open-HyperVmgmt.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-HyperVmgmt
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-HyperVmgmt')]
    [Alias('hyperv')]
    param()
    try {
        $ErrorActionPreference = "Stop"
        virtmgmt.msc
    } catch {
        Write-Output "Hyper-V management tools not installed/enabled."
    }
}
