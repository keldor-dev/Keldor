function Stop-AxwayTrayApp {
<#
.SYNOPSIS
    Short description

.DESCRIPTION
    Long description

.EXAMPLE
    Stop-AxwayTrayApp
    Example of how to use this cmdlet

.EXAMPLE
    Stop-AxwayTrayApp -PARAMETER
    Another example of how to use this cmdlet but with a parameter or switch.

.OUTPUTS
    None

.NOTES
    Author: Skyler Hart
    Created: 2021-06-16 23:28:20
    Last Edit: 2021-06-16 23:28:20
    Keywords:
    Other:
    Requires:
    -Module ActiveDirectory
    -PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
    -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Stop-AxwayTrayApp
#>





        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Stop-AxwayTrayApp')]
    Param ()
Get-Process | Where-Object {$_.Name -match "dvtray"} | Stop-Process -Force
}
