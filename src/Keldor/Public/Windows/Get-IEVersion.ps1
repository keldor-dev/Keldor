function Get-IEVersion {
<#
.SYNOPSIS
    Gets IE Version.

.DESCRIPTION
    Gets IE Version.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Get-IEVersion
    Runs Get-IEVersion.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-IEVersion
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-IEVersion')]
    Param (
        [Parameter(
            Mandatory=$false,
            Position=0
        )]
        [Alias('Host','Name','Computer','CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    $keyname = 'SOFTWARE\\Microsoft\\Internet Explorer'
    foreach ($comp in $ComputerName) {
        $reg = $null
        $key = $null
        $value = $null
        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $comp)
        $key = $reg.OpenSubkey($keyname)
        $value = $key.GetValue('Version')
        [PSCustomObject]@{
            ComputerName = $comp
            IEVersion = $value
        }# new object
    }# foreach computer
}
