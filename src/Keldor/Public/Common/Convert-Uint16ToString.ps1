function Convert-Uint16ToString {
<#
.SYNOPSIS
    Converts uin16 arrays to a readable string.

.DESCRIPTION
    Take the members from a uint16 array and converts it to a user friendly string.

.PARAMETER Members
    Takes the array members for a uint16 array.

.EXAMPLE
    Convert-Uint16ToString $uint16array
    Converts the uint16 array in the $uint16array variable.

.EXAMPLE
    Convert-Uint16ToString ((Get-CimInstance WmiMonitorID -Namespace root/WMI)[0] | Select-Object -ExpandProperty SerialNumberID)
    Converts the SerialNumberID of the first monitor to a readable format.

.OUTPUTS
    System.String

.NOTES
    Author: Skyler Hart
    Created: 2023-02-11 01:02:00
    Last Edit: 2023-02-11 01:02:00

.LINK
    https://docs.keldor.dev/powershell/keldor/Convert-Uint16ToString
#>







    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Convert-Uint16ToString')]
    param(
        [Parameter()]
        [uint16[]]$Members
    )

    Process {
        -join [char[]] ($Members)
    }
}
