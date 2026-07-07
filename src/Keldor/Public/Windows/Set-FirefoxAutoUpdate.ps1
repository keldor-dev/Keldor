function Set-FirefoxAutoUpdate {
<#
.SYNOPSIS
    Sets Firefox Auto Update.

.DESCRIPTION
    Sets Firefox Auto Update.

.PARAMETER ComputerName
    Specifies the computer name to use.

.PARAMETER Enable
    Specifies whether to enable the Enable option.

.EXAMPLE
    Set-FirefoxAutoUpdate
    Runs Set-FirefoxAutoUpdate.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-FirefoxAutoUpdate
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-FirefoxAutoUpdate')]
    Param (
        [Parameter(
            Mandatory=$false,
            Position=0
        )]
        [Alias('Host','Name','Computer','CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME",

        [Parameter()]
        [Switch]$Enable
    )

    $v1 = 'DisableAppUpdate'
    if ($Enable) {$d = 0}
    else {$d = 1}

    $i = 0
    $number = $ComputerName.length

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        foreach ($comp in $ComputerName) {
            #Progress Bar
            if ($number -gt "1") {
                $i++
                $amount = ($i / $number)
                $perc1 = $amount.ToString("P")
                Write-Progress -activity "Setting Firefox Auto Update value" -status "Computer $i of $number. Percent complete:  $perc1" -PercentComplete (($i / $ComputerName.length)  * 100)
            }#if length

            if ($PSCmdlet.ShouldProcess($comp, "Set Firefox auto update")) {
                ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)).CreateSubKey('SOFTWARE\Policies\Mozilla\Firefox')
                $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)
                $SubKey = $BaseKey.OpenSubKey('SOFTWARE\Policies\Mozilla\Firefox',$true)
                $SubKey.SetValue($v1, $d, [Microsoft.Win32.RegistryValueKind]::DWORD)
            }
        }#foreach computer
    }#if admin
    else {Write-Error "Set-FirefoxAutoUpdate must be ran as administrator"}
}
