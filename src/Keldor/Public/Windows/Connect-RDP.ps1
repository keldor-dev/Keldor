function Connect-RDP {
    <#
.SYNOPSIS
    Establishes a Remote Desktop Protocol (RDP) connection to a specified computer.

.DESCRIPTION
    This function allows the user to connect to a remote computer via RDP. If a computer name is provided, it connects to that specific computer. If no computer name is provided, it will open the RDP client without specifying a target.

.PARAMETER ComputerName
    Specifies the name of the computer to which you want to connect. This parameter is optional. If omitted, the RDP client will open without a specified target.

.EXAMPLE
    Connect-RDP -ComputerName "Server01"
    Connects to the computer named "Server01" using RDP.

.EXAMPLE
    Connect-RDP
    Opens the RDP client without specifying a target computer.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Connect-RDP
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Connect-RDP')]
    [alias('rdp')]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string]$ComputerName
    )

    if (!([string]::IsNullOrWhiteSpace($ComputerName))) {
        mstsc /v:$ComputerName /admin
    } else {
        mstsc
    }
}
