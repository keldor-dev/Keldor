function Stop-AppService {
    <#
.SYNOPSIS
    Stops App Service.

.DESCRIPTION
    Stops App Service.

.EXAMPLE
    Stop-AppService
    Runs Stop-AppService.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Stop-AppService
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Stop-AppService')]
    param ()
    $AppNames = ($Global:KeldorConfig).AppNames
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $services = Get-Service | Where-Object { $_.Status -eq "Running" }
        foreach ($app in $AppNames) {
            $services | Where-Object { $_.DisplayName -match $app -or $_.Name -match $app } | ForEach-Object {
                if ($PSCmdlet.ShouldProcess($_.Name, "Stop service")) {
                    $_ | Stop-Service -Force
                }
            }
        }
    } else {
        Write-Output "Must run PowerShell as admin to run Stop-AppService."
    }
    Write-Output "Completed stopping application services."
}
