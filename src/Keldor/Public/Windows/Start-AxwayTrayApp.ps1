function Start-AxwayTrayApp {
<#
.SYNOPSIS
    Short description

.DESCRIPTION
    Long description

.EXAMPLE
    Start-AxwayTrayApp
    Example of how to use this cmdlet

.EXAMPLE
    Start-AxwayTrayApp -PARAMETER
    Another example of how to use this cmdlet but with a parameter or switch.

.OUTPUTS
    None

.NOTES
    Author: Skyler Hart
    Created: 2021-06-16 23:27:38
    Last Edit: 2021-06-16 23:27:38
    Keywords:
    Other:
    Requires:
    -Module ActiveDirectory
    -PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
    -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Start-AxwayTrayApp
#>





        [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Start-AxwayTrayApp')]
    Param ()
if ($PSCmdlet.ShouldProcess('C:\Program Files\Tumbleweed\Desktop Validator\DVTrayApp.exe', "Start Axway tray app")) {
    & 'C:\Program Files\Tumbleweed\Desktop Validator\DVTrayApp.exe'
}
}
