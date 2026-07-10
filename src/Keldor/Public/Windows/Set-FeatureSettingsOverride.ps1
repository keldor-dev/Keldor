function Set-FeatureSettingsOverride {
    <#
.SYNOPSIS
    Sets Feature Settings Override.

.DESCRIPTION
    Sets Feature Settings Override.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Set-FeatureSettingsOverride
    Runs Set-FeatureSettingsOverride.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-FeatureSettingsOverride
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-FeatureSettingsOverride')]
    param (
        [Parameter(
            Mandatory = $false,
            Position = 0
        )]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    $RES = @()
    $infos = @()
    $infos += @{
        Value = 'FeatureSettingsOverride'
        Data  = 72
    }
    $infos += @{
        Value = 'FeatureSettingsOverrideMask'
        Data  = 3
    }


    foreach ($info in $infos) {
        $RES += [PSCustomObject]$info
    }


    $i = 0
    $number = $ComputerName.length
    foreach ($comp in $ComputerName) {
        #Progress Bar
        if ($number -gt "1") {
            $i++
            $amount = ($i / $number)
            $perc1 = $amount.ToString("P")
            Write-Progress -Activity "Setting remediation values" -Status "Computer $i of $number. Percent complete:  $perc1" -PercentComplete (($i / $ComputerName.length) * 100)
        }#if length

        foreach ($RE in $RES) {
            $ValueName = $RE.Value
            $ValueData = $RE.Data
            if ($PSCmdlet.ShouldProcess($comp, "Set $ValueName")) {
                ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)).CreateSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management')
                $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $comp)
                $SubKey = $BaseKey.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management', $true)
                $SubKey.SetValue($ValueName, $ValueData, [Microsoft.Win32.RegistryValueKind]::DWORD)
            }
        }
    }#foreach computer
}
