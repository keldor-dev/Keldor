function Enable-RC4 {
    <#
.SYNOPSIS
    Enables RC4.

.DESCRIPTION
    Enables RC4.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Enable-RC4
    Runs Enable-RC4.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Enable-RC4
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Enable-RC4')]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    $ValueName = "Enabled"
    $Valuedata = 1

    foreach ($comp in $ComputerName) {
        #.
        #. Ciphers
        #.

        #Enable RC4
        if ($PSCmdlet.ShouldProcess($comp, "Enable RC4")) {
            ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)).CreateSubKey('System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128')
            $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)
            $SubKey = $BaseKey.OpenSubKey('System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128', $true)
            $SubKey.SetValue($ValueName, $ValueData, [Microsoft.Win32.RegistryValueKind]::DWORD)

            ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)).CreateSubKey('System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64/128')
            $SubKey = $BaseKey.OpenSubKey('System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64/128', $true)
            $SubKey.SetValue($ValueName, $ValueData, [Microsoft.Win32.RegistryValueKind]::DWORD)

            ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)).CreateSubKey('System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128')
            $SubKey = $BaseKey.OpenSubKey('System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128', $true)
            $SubKey.SetValue($ValueName, $ValueData, [Microsoft.Win32.RegistryValueKind]::DWORD)

            ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)).CreateSubKey('System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128')
            $SubKey = $BaseKey.OpenSubKey('System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128', $true)
            $SubKey.SetValue($ValueName, $ValueData, [Microsoft.Win32.RegistryValueKind]::DWORD)
        }
    }
}#function enable rc4
