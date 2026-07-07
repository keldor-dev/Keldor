function Restart-AxwayTrayApp {
<#
.SYNOPSIS
    Short description

.DESCRIPTION
    Long description

.EXAMPLE
    Restart-AxwayTrayApp
    Example of how to use this cmdlet

.EXAMPLE
    Restart-AxwayTrayApp -PARAMETER
    Another example of how to use this cmdlet but with a parameter or switch.

.OUTPUTS
    None

.NOTES
    Author: Skyler Hart
    Created: 2021-06-16 23:25:56
    Last Edit: 2021-06-16 23:25:56
    Keywords:
    Other:
    Requires:
    -Module ActiveDirectory
    -PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
    -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Restart-AxwayTrayApp
#>





        [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Restart-AxwayTrayApp')]
    Param ()
Get-Process | Where-Object {$_.Name -match "dvtray"} | ForEach-Object {
    if ($PSCmdlet.ShouldProcess($_.Name, "Stop process")) {
        $_ | Stop-Process -Force | Out-Null
    }
}
    if ($PSCmdlet.ShouldProcess('C:\Program Files\Tumbleweed\Desktop Validator\DVTrayApp.exe', "Start Axway tray app")) {
        & 'C:\Program Files\Tumbleweed\Desktop Validator\DVTrayApp.exe'
    }
}
