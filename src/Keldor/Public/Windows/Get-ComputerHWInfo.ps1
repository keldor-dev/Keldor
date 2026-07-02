function Get-ComputerHWInfo {
<#
.SYNOPSIS
    Gets hardware information of local or remote computer(s).

.DESCRIPTION
    Get Manufacturer, Model, Model Version, BIOS vendor, BIOS version, and release date of BIOS update on local or remote computer.

.PARAMETER ComputerName
    Used to specify the computer or computers to get hardware information for.

.EXAMPLE
    Get-ComputerHWInfo
    Get hardware information for local computer

.EXAMPLE
    Get-ComputerHWInfo COMP1
    Get hardware information for computer COMP1

.OUTPUTS
    System.Object

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 3/15/2015 08:49:13
    LASTEDIT: 09/21/2017 13:03:30
    KEYWORDS: hardware, information, computer
    REQUIRES:
        -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-ComputerHWInfo
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-ComputerHWInfo')]
    Param (
        [Parameter(
            Mandatory=$false,
            Position=0
        )]
        [Alias('Host','Name','Computer','CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    $keyname = 'HARDWARE\\DESCRIPTION\\System\\BIOS'
    foreach ($comp in $ComputerName) {
        $reg = $null
        $key = $null
        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $comp)
        $key = $reg.OpenSubkey($keyname)
        $BRD = $key.GetValue('BIOSReleaseDate')
        $BV = $key.GetValue('BIOSVendor')
        $Bver = $key.GetValue('BIOSVersion')
        $SM = $key.GetValue('SystemManufacturer')
        $SPN = $key.GetValue('SystemProductName')
        $SV = $key.GetValue('SystemVersion')

        [PSCustomObject]@{
            ComputerName = $comp
            Manufacturer = $SM
            Model = $SPN
            ModelVersion = $SV
            BIOSVendor = $BV
            BIOSVersion = $Bver
            BIOSReleaseDate = $BRD
        }# new object
    }# foreach computer
}
