function Set-RemoteDesktopCert {
<#
.SYNOPSIS
    Sets Remote Desktop Cert.

.DESCRIPTION
    Sets Remote Desktop Cert.

.PARAMETER Thumbprint
    Specifies the Thumbprint value.

.EXAMPLE
    Set-RemoteDesktopCert -Thumbprint <value>
    Runs Set-RemoteDesktopCert.

.OUTPUTS
    System.Object

.NOTES
    Author: Skyler Hart
    Created: 2021-11-18 22:53:02
    Last Edit: 2021-11-18 22:53:02
    Keywords:
    Requires:
    -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-RemoteDesktopCert
#>





    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-RemoteDesktopCert')]
    [Alias('Set-RDPCert')]
    param(
        [Parameter(
            HelpMessage = "Enter the thumbprint of the certificate.",
            Mandatory=$true
        )]
        [Alias('Cert')]
        [string]$Thumbprint
    )

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $tsgs = Get-WmiObject -Class Win32_TSGeneralSetting -Namespace root\cimV2\terminalservices -Filter "TerminalName='RDP-tcp'"
        if ($PSCmdlet.ShouldProcess('RDP-tcp', "Set Remote Desktop certificate")) {
            Set-WmiInstance -Path $tsgs.__path -argument @{SSLCertificateSHA1Hash="$Thumbprint"} #DevSkim: ignore DS126858
        }
    }
    else {Write-Error "Must be ran as administrator."}
}
