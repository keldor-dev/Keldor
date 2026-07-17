function Start-AxwayTrayApp {
    <#
.SYNOPSIS
    Starts the Axway Desktop Validator tray application.

.DESCRIPTION
    Starts the Axway Desktop Validator tray application from its standard installation path.

.EXAMPLE
    Start-AxwayTrayApp

    Starts the Axway tray application after confirmation.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Start-AxwayTrayApp
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Start-AxwayTrayApp')]
    param ()
    if ($PSCmdlet.ShouldProcess('C:\Program Files\Tumbleweed\Desktop Validator\DVTrayApp.exe', "Start Axway tray app")) {
        & 'C:\Program Files\Tumbleweed\Desktop Validator\DVTrayApp.exe'
    }
}
