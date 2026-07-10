function Get-Drive {
    <#
.SYNOPSIS
    Gets Drive.

.DESCRIPTION
    Gets Drive.

.EXAMPLE
    Get-Drive
    Runs Get-Drive.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-Drive
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-Drive')]
    [Alias('drive')]
    param()
    Get-PSDrive -Name *
}
