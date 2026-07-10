function Disable-ServerManager {
    <#
.SYNOPSIS
    Disables the Server Manager from launching automatically on the local computer.

.DESCRIPTION
    This function disables the Server Manager from launching automatically on the local computer by disabling the related scheduled task. It requires administrative privileges to execute.

.EXAMPLE
    Disable-ServerManager
    Disables the Server Manager from launching automatically on the local computer.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Disable-ServerManager
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Disable-ServerManager')]
    param ()

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        if ($PSCmdlet.ShouldProcess('ServerManager', "Disable scheduled task")) {
            Get-ScheduledTask -TaskName "ServerManager" | Disable-ScheduledTask
        }
    } else {
        throw "Must be run as administrator."
    }
}
