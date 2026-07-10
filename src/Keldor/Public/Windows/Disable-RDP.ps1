function Disable-RDP {
    <#
.SYNOPSIS
    Disables Remote Desktop Protocol (RDP) on the local computer.

.DESCRIPTION
    This function disables RDP on the local computer by modifying the appropriate registry key to deny RDP connections. It requires administrative privileges to execute.

.EXAMPLE
    Disable-RDP
    Disables RDP on the local computer.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Disable-RDP
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Disable-RDP')]
    param ()

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        if ($PSCmdlet.ShouldProcess('HKLM:\System\CurrentControlSet\Control\Terminal Server\fDenyTSConnections', "Set to 1")) {
            Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 1
        }
    } else {
        throw "Must be run as administrator."
    }
}
