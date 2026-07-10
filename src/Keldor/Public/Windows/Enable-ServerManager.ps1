function Enable-ServerManager {
    <#
.SYNOPSIS
    Enables the Server Manager to launch automatically on the local computer.

.DESCRIPTION
    This function enables the Server Manager to launch automatically on the local computer by enabling the related scheduled task. It requires administrative privileges to execute.

.EXAMPLE
    Enable-ServerManager
    Enables the Server Manager to launch automatically on the local computer.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Enable-ServerManager
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Enable-ServerManager')]
    param ()

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        if ($PSCmdlet.ShouldProcess('ServerManager', "Enable scheduled task")) {
            Get-ScheduledTask -TaskName "ServerManager" | Enable-ScheduledTask
        }
    } else {
        throw "Must be run as administrator."
    }
}
