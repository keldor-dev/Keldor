function Open-NetworkConnections {
    <#
.SYNOPSIS
    Opens Network Connections.

.DESCRIPTION
    Opens Network Connections.

.EXAMPLE
    Open-NetworkConnections
    Runs Open-NetworkConnections.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-NetworkConnections
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-NetworkConnections')]
    [Alias('network', 'connections')]
    param()
    control.exe ncpa.cpl
}
