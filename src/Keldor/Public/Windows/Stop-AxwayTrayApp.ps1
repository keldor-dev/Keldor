function Stop-AxwayTrayApp {
    <#
.SYNOPSIS
    Stops the Axway Desktop Validator tray application.

.DESCRIPTION
    Finds dvtray processes and stops each process after confirmation.

.EXAMPLE
    Stop-AxwayTrayApp

    Stops running Axway tray processes after confirmation.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Stop-AxwayTrayApp
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Stop-AxwayTrayApp')]
    param ()
    Get-Process | Where-Object { $_.Name -match "dvtray" } | ForEach-Object {
        if ($PSCmdlet.ShouldProcess($_.Name, "Stop process")) {
            $_ | Stop-Process -Force
        }
    }
}
