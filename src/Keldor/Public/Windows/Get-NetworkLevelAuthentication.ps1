function Get-NetworkLevelAuthentication {
<#
.SYNOPSIS
    Gets Network Level Authentication.

.DESCRIPTION
    Gets Network Level Authentication.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Get-NetworkLevelAuthentication
    Runs Get-NetworkLevelAuthentication.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-NetworkLevelAuthentication
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-NetworkLevelAuthentication')]
    [Alias('Get-NLA')]
    param(
        [Parameter(
            Mandatory=$false
        )]
        [Alias('Host','Name','Computer','CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    foreach ($Comp in $ComputerName) {
        try {
            $ErrorActionPreference = "Stop"
            $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Comp)
            $key = $reg.OpenSubKey("SYSTEM\\CurrentControlSet\\Control\\Terminal Server\\WinStations\\RDP-Tcp")
            [Bool]$ua = $key.GetValue('UserAuthentication')

            [PSCustomObject]@{
                ComputerName = $Comp
                UserAuthentication = $ua
            }#new object
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
        catch {
            [PSCustomObject]@{
                ComputerName = $Comp
                UserAuthentication = "Unknown error"
            }#new object
        }
    }
}
