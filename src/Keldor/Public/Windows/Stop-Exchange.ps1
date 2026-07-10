function Stop-Exchange {
    <#
.SYNOPSIS
    Stops Exchange.

.DESCRIPTION
    Stops Exchange.

.EXAMPLE
    Stop-Exchange
    Runs Stop-Exchange.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Stop-Exchange
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Stop-Exchange')]
    param ()
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Get-Service -Name * | Where-Object { $_.DisplayName -match "Exchange" } | ForEach-Object {
            if ($PSCmdlet.ShouldProcess($_.Name, "Stop service")) {
                $_ | Stop-Service -Force
            }
        }
    } else {
        Write-Output "Must run PowerShell as admin to run Stop-Exchange."
    }
}
