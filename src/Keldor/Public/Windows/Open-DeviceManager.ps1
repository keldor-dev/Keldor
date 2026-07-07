function Open-DeviceManager {
<#
.SYNOPSIS
    Opens Device Manager.

.DESCRIPTION
    Opens Device Manager.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Open-DeviceManager
    Runs Open-DeviceManager.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-DeviceManager
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-DeviceManager')]
    Param (
        [Parameter(Mandatory=$false, Position=0)]
        [Alias('Host','Name','Computer','CN')]
        [string]$ComputerName = "$env:COMPUTERNAME"
    )
    devmgmt.msc /computer:\\$ComputerName
}
