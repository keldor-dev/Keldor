function Enable-3DES {
<#
.SYNOPSIS
    Enables 3 DES.

.DESCRIPTION
    Enables 3 DES.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Enable-3DES
    Runs Enable-3DES.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Enable-3DES
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Enable-3DES')]
    Param (
        [Parameter(Mandatory=$false, Position=0)]
        [Alias('Host','Name','Computer','CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    $ValueName = "Enabled"
    $Valuedata = 1

    foreach ($comp in $ComputerName) {
        #.
        #. Ciphers
        #.

        #Enable Triple DES #############remove trailing /168 for everything 2008R2/7 and newer
        $wmiq = Get-WmiObject Win32_OperatingSystem -ComputerName $Comp -ErrorAction Stop
        $os = $wmiq.Caption
        if ($PSCmdlet.ShouldProcess($comp, "Enable Triple DES")) {
            if ($os -match "Windows 7" -or $os -match "Windows Server 2008 R2" -or $os -match "2012" -or $os -match "2016") {
                ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)).CreateSubKey('System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168') #DevSkim: ignore DS106863
                $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)
                $SubKey = $BaseKey.OpenSubKey('System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168',$true) #DevSkim: ignore DS106863
                $SubKey.SetValue($ValueName, $ValueData, [Microsoft.Win32.RegistryValueKind]::DWORD)
            }
            else {
                ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)).CreateSubKey('System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168/168') #DevSkim: ignore DS106863
                $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)
                $SubKey = $BaseKey.OpenSubKey('System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168/168',$true) #DevSkim: ignore DS106863
                $SubKey.SetValue($ValueName, $ValueData, [Microsoft.Win32.RegistryValueKind]::DWORD)
            }
        }
    }
}#function enable 3des
