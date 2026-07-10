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
