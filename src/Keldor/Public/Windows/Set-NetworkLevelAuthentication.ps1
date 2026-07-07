function Set-NetworkLevelAuthentication {
<#
.SYNOPSIS
    Sets Network Level Authentication.

.DESCRIPTION
    Sets Network Level Authentication.

.PARAMETER ComputerName
    Specifies the computer name to use.

.PARAMETER Disable
    Specifies to disable Network Level Authentication. Without this NLA will be enabled.

.EXAMPLE
    Set-NetworkLevelAuthentication
    Will enable network level authentication on the local computer.

.EXAMPLE
    Set-NetworkLevelAuthentication -Disable
    Will disable network level authentication on the local computer.

.EXAMPLE
    Set-NetworkLevelAuthentication -ComputerName COMP1
    Will enable network level authentication on the computer COMP1.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-NetworkLevelAuthentication
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-NetworkLevelAuthentication')]
    [Alias('Set-NLA')]
    param(
        [Parameter(
            Mandatory=$false,
            Position=0
        )]
        [Alias('Host','Name','Computer','CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME",

        [Parameter(
            Mandatory=$false
        )]
        [Switch]$Disable
    )

    foreach ($Comp in $ComputerName) {
        try {
            $ErrorActionPreference = "Stop"
            $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Comp)
            $key = $reg.OpenSubKey("SYSTEM\\CurrentControlSet\\Control\\Terminal Server\\WinStations\\RDP-Tcp",$true)
            if ($PSCmdlet.ShouldProcess($Comp, "Set Network Level Authentication")) {
                if ($Disable) {
                    $key.SetValue('UserAuthentication', 0, [Microsoft.Win32.RegistryValueKind]::DWORD)
                }
                else {
                    $key.SetValue('UserAuthentication', 1, [Microsoft.Win32.RegistryValueKind]::DWORD)
                }
            }
        }
        catch [System.Management.Automation.MethodInvocationException] {
            $err = $_.Exception.message.Trim()
            if ($err -match "network path") {
                $ua = "Could not connect"
            }
            elseif ($err -match "access is not allowed") {
                $ua = "Insufficient permissions"
            }
            else {
                $ua = "Unknown error"
            }
            [PSCustomObject]@{
                ComputerName = $Comp
                UserAuthentication = $ua
            }#new object
        }
    }
}
