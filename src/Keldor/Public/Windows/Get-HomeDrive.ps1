function Get-HomeDrive {
<#
.SYNOPSIS
    Gets Home Drive.

.DESCRIPTION
    Gets Home Drive.

.EXAMPLE
    Get-HomeDrive
    Runs Get-HomeDrive.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-HomeDrive
#>

        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-HomeDrive')]
    Param ()
$env:HOMESHARE
}
