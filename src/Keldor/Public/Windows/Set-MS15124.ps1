function Set-MS15124 {
    <#
.SYNOPSIS
    Sets MS15124.

.DESCRIPTION
    Sets MS15124.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Set-MS15124
    Runs Set-MS15124.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-MS15124
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-MS15124')]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    $ValueName = "iexplore.exe"
    $Valuedata = 1

    foreach ($comp in $ComputerName) {
        if ($PSCmdlet.ShouldProcess($comp, "Set MS15-124 registry values")) {
            ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)).CreateSubKey('SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING')
            $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)
            $SubKey = $BaseKey.OpenSubKey('SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING', $true)
            $SubKey.SetValue($ValueName, $ValueData, [Microsoft.Win32.RegistryValueKind]::DWORD)

            ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)).CreateSubKey('SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING')
            $SubKey = $BaseKey.OpenSubKey('SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING', $true)
            $SubKey.SetValue($ValueName, $ValueData, [Microsoft.Win32.RegistryValueKind]::DWORD)
        }
    }
}#function set-ms15-124
