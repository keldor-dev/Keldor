function Enable-TLS1.0 {
    #DevSkim: ignore DS169125,DS440000







    <#
.SYNOPSIS
    Enables TLS1.0.

.DESCRIPTION
    Enables TLS1.0.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Enable-TLS1.0
    Runs Enable-TLS1.0.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Enable-TLS1.0
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Enable-TLS1.0')]
    param(
        [Parameter(
            Mandatory = $false,
            Position = 0
        )]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    $ValueName = "Enabled"
    $ValueName2 = "DisabledByDefault"
    $Valuedata = 0
    $Valuedata2 = 1

    foreach ($Comp in $ComputerName) {
        if ($PSCmdlet.ShouldProcess($Comp, "Enable TLS 1.0")) {
            ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)).CreateSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0')
            ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)).CreateSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client')
            ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)).CreateSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server')
            $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)
            $SubKey = $BaseKey.OpenSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client', $true)
            $SubKey.SetValue($ValueName, $ValueData2, [Microsoft.Win32.RegistryValueKind]::DWORD)
            $SubKey.SetValue($ValueName2, $ValueData, [Microsoft.Win32.RegistryValueKind]::DWORD)

            $SubKey2 = $BaseKey.OpenSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server', $true)
            $SubKey2.SetValue($ValueName, $ValueData2, [Microsoft.Win32.RegistryValueKind]::DWORD)
            $SubKey2.SetValue($ValueName2, $ValueData, [Microsoft.Win32.RegistryValueKind]::DWORD)
        }
    }
}
