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

.LINK
    https://docs.keldor.dev/powershell/keldor/Start-AxwayTrayApp
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Start-AxwayTrayApp')]
    param ()
    if ($PSCmdlet.ShouldProcess('C:\Program Files\Tumbleweed\Desktop Validator\DVTrayApp.exe', "Start Axway tray app")) {
        & 'C:\Program Files\Tumbleweed\Desktop Validator\DVTrayApp.exe'
    }
}
