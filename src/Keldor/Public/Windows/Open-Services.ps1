function Open-Services {
    <#
.SYNOPSIS
    Opens Services.

.DESCRIPTION
    Opens Services.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Open-Services
    Runs Open-Services.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-Services
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-Services')]
    [Alias('services')]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string]$ComputerName = "$env:COMPUTERNAME"
    )
    services.msc /computer=\\$ComputerName
}
