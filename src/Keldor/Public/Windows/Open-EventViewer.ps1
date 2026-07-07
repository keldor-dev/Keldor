function Open-EventViewer {
<#
.SYNOPSIS
    Opens Event Viewer.

.DESCRIPTION
    Opens Event Viewer.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Open-EventViewer
    Runs Open-EventViewer.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-EventViewer
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-EventViewer')]
    [Alias('events')]
    Param (
        [Parameter(Mandatory=$false, Position=0)]
        [Alias('Host','Name','Computer','CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )
    eventvwr.msc /computer:\\$ComputerName
}
