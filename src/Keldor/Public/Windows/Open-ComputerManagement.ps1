function Open-ComputerManagement {
<#
.SYNOPSIS
    Opens Computer Management.

.DESCRIPTION
    Opens Computer Management.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Open-ComputerManagement
    Runs Open-ComputerManagement.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-ComputerManagement
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-ComputerManagement')]
    Param (
        [Parameter(Mandatory=$false, Position=0)]
        [Alias('Host','Name','Computer','CN')]
        [string]$ComputerName = "$env:COMPUTERNAME"
    )
    compmgmt.msc /computer:\\$ComputerName
}
