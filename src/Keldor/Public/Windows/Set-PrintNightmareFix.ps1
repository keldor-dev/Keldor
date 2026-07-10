function Set-PrintNightmareFix {
    <#
.SYNOPSIS
    Sets Print Nightmare Fix.

.DESCRIPTION
    Sets Print Nightmare Fix.

.PARAMETER ComputerName
    Specifies the computer name to use.

.PARAMETER DisableSpooler
    Specifies whether to enable the Disable Spooler option.

.EXAMPLE
    Set-PrintNightmareFix
    Runs Set-PrintNightmareFix.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-PrintNightmareFix
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-PrintNightmareFix')]
    param(
        [Parameter(
            Mandatory = $false,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME",

        [switch]$DisableSpooler
    )

    $v1 = 'NoWarningNoElevationOnInstall'
    $v2 = 'UpdatePromptSettings'
    $v3 = 'RestrictDriverInstallationToAdministrators'
    $d0 = 0
    $d1 = 1

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        foreach ($Comp in $ComputerName) {
            if ($PSCmdlet.ShouldProcess($Comp, "Set PrintNightmare registry values")) {
                ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)).CreateSubKey('SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint')
                $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)
                $SubKey = $BaseKey.OpenSubKey('SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint', $true)
                $SubKey.SetValue($v1, $d0, [Microsoft.Win32.RegistryValueKind]::DWORD)

                $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)
                $SubKey = $BaseKey.OpenSubKey('SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint', $true)
                $SubKey.SetValue($v2, $d0, [Microsoft.Win32.RegistryValueKind]::DWORD)

                $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)
                $SubKey = $BaseKey.OpenSubKey('SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint', $true)
                $SubKey.SetValue($v3, $d1, [Microsoft.Win32.RegistryValueKind]::DWORD)
            }

            if ($Comp -eq $env:COMPUTERNAME) {
                if ($DisableSpooler) {
                    if ($PSCmdlet.ShouldProcess('Spooler', "Stop and disable service")) {
                        Stop-Service -Name Spooler -Force | Out-Null
                        Set-Service -Name Spooler -StartupType Disabled
                    }
                }
            }
        }#foreach computer
    } else { Write-Error "Must be ran as administrator" }
}
