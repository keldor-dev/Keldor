function Disable-DiffieHellman {
    <#
.SYNOPSIS
    Disables Diffie Hellman.

.DESCRIPTION
    Disables Diffie Hellman.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Disable-DiffieHellman
    Runs Disable-DiffieHellman.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Disable-DiffieHellman
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Disable-DiffieHellman')]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    $ValueName = "Enabled"
    $Valuedata = 0

    foreach ($comp in $ComputerName) {
        #.
        #. Ciphers
        #.

        #Disable Diffie-Hellman
        if ($PSCmdlet.ShouldProcess($comp, "Disable Diffie-Hellman")) {
            ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)).CreateSubKey('System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms')
            ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)).CreateSubKey('System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\Diffie-Hellman')
            $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)
            $SubKey = $BaseKey.OpenSubKey('System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\Diffie-Hellman', $true)
            $SubKey.SetValue($ValueName, $ValueData, [Microsoft.Win32.RegistryValueKind]::DWORD)
        }
    }
}#function disable diffie-hellman
