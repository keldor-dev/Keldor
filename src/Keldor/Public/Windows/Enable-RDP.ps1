function Enable-RDP {
<#
.SYNOPSIS
    Enables Remote Desktop Protocol (RDP) on the local computer.

.DESCRIPTION
    This function enables RDP on the local computer by modifying the appropriate registry key to allow RDP connections. It requires administrative privileges to execute.

.EXAMPLE
    Enable-RDP
    Enables RDP on the local computer.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Enable-RDP
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Enable-RDP')]
    param ()

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        if ($PSCmdlet.ShouldProcess('HKLM:\System\CurrentControlSet\Control\Terminal Server\fDenyTSConnections', "Set to 0")) {
            Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
        }
    } else {
        throw "Must be run as administrator."
    }
}
