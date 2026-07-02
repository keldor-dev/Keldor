function Open-HyperVmgmt {
<#
.Notes
    AUTHOR: Skyler Hart
    CREATED: 08/19/2017 22:32:48
    LASTEDIT: 2022-09-04 12:13:29
    KEYWORDS:
.LINK
    https://docs.keldor.dev/powershell/keldor/Open-HyperVmgmt
#>
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-HyperVmgmt')]
    [Alias('hyperv')]
    param()
    try {
        $ErrorActionPreference = "Stop"
        virtmgmt.msc
    }
    catch {
        Write-Output "Hyper-V management tools not installed/enabled."
    }
}
