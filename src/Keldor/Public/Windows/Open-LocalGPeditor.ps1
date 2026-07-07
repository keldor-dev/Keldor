function Open-LocalGPeditor {
<#
.SYNOPSIS
    Opens Local G Peditor.

.DESCRIPTION
    Opens Local G Peditor.

.EXAMPLE
    Open-LocalGPeditor
    Runs Open-LocalGPeditor.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-LocalGPeditor
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-LocalGPeditor')]
    [Alias('Open-LocalPolicyEditor','LocalPolicy')]
    param()
    gpedit.msc
}
