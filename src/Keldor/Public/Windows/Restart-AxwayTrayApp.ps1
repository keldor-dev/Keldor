function Restart-AxwayTrayApp {
    <#
.SYNOPSIS
    Restarts the Axway Desktop Validator tray application.

.DESCRIPTION
    Stops running dvtray processes and starts the Axway Desktop Validator tray application from its standard path.

.EXAMPLE
    Restart-AxwayTrayApp

    Restarts the Axway tray application after confirmation.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Restart-AxwayTrayApp
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Restart-AxwayTrayApp')]
    param ()
    Get-Process | Where-Object { $_.Name -match "dvtray" } | ForEach-Object {
        if ($PSCmdlet.ShouldProcess($_.Name, "Stop process")) {
            $_ | Stop-Process -Force | Out-Null
        }
    }
    if ($PSCmdlet.ShouldProcess('C:\Program Files\Tumbleweed\Desktop Validator\DVTrayApp.exe', "Start Axway tray app")) {
        & 'C:\Program Files\Tumbleweed\Desktop Validator\DVTrayApp.exe'
    }
}
