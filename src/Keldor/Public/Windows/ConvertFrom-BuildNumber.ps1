function ConvertFrom-BuildNumber {
<#
.SYNOPSIS
    Converts a Microsoft Build number to a version number.

.DESCRIPTION
    Takes a build number for Windows 8/Server 2012 or newer and converts it to a version number and Operatiing System.

.PARAMETER BuildNumber
    Specifies the number of the Microsoft Build.

.EXAMPLE
    ConvertFrom-BuildNumber 20348
    Example of how to use this cmdlet. This example will return Windows Server 2022.

.OUTPUTS
    System.Management.Automation.PSCustomObject

.LINK
    https://docs.keldor.dev/powershell/keldor/ConvertFrom-BuildNumber
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/ConvertFrom-BuildNumber')]
    [Alias('ConvertFrom-MicrosoftBuildNumber')]
    param(
        [Parameter(
            Mandatory=$true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Build')]
        [int32[]] $BuildNumber
    )

    Process {
        foreach ($Build in $BuildNumber) {
            if ($Build -eq 9200) {
                [PSCustomObject]@{
                    OS = "Windows 8 or Windows Server 2012"
                    Build = $Build
                    Version ="6.2"
                }
            }
            elseif ($Build -eq 9600) {
                [PSCustomObject]@{
                    OS = "Windows 8.1 or Windows Server 2012 R2"
                    Build = $Build
                    Version ="6.3"
                }
            }
            elseif ($Build -eq 14393) {
                [PSCustomObject]@{
                    OS = "Windows 10 or Windows Server 2016"
                    Build = $Build
                    Version ="1607"
                }
            }
            elseif ($Build -eq 15063) {
                [PSCustomObject]@{
                    OS = "Windows 10"
                    Build = $Build
                    Version ="1703"
                }
            }
            elseif ($Build -eq 16299) {
                [PSCustomObject]@{
                    OS = "Windows 10"
                    Build = $Build
                    Version ="1709"
                }
            }
            elseif ($Build -eq 17134) {
                [PSCustomObject]@{
                    OS = "Windows 10"
                    Build = $Build
                    Version ="1803"
                }
            }
            elseif ($Build -eq 17763) {
                [PSCustomObject]@{
                    OS = "Windows 10 or Windows Server 2019"
                    Build = $Build
                    Version ="1809"
                }
            }
            elseif ($Build -eq 18362) {
                [PSCustomObject]@{
                    OS = "Windows 10"
                    Build = $Build
                    Version ="1903"
                }
            }
            elseif ($Build -eq 18363) {
                [PSCustomObject]@{
                    OS = "Windows 10"
                    Build = $Build
                    Version ="1909"
                }
            }
            elseif ($Build -eq 19041) {
                [PSCustomObject]@{
                    OS = "Windows 10"
                    Build = $Build
                    Version ="2004"
                }
            }
            elseif ($Build -eq 19042) {
                [PSCustomObject]@{
                    OS = "Windows 10"
                    Build = $Build
                    Version ="20H2 (2009)"
                }
            }
            elseif ($Build -eq 19043) {
                [PSCustomObject]@{
                    OS = "Windows 10"
                    Build = $Build
                    Version ="21H1 (2103)"
                }
            }
            elseif ($Build -eq 19044) {
                [PSCustomObject]@{
                    OS = "Windows 10"
                    Build = $Build
                    Version ="21H2 (2109)"
                }
            }
            elseif ($Build -eq 22000) {
                [PSCustomObject]@{
                    OS = "Windows 11"
                    Build = $Build
                    Version ="21H2 (2109)"
                }
            }
            elseif ($Build -eq 20348) {
                [PSCustomObject]@{
                    OS = "Windows Server 2022"
                    Build = $Build
                    Version ="21H2 (2109)"
                }
            }
            elseif ($Build -eq 19045) {
                [PSCustomObject]@{
                    OS = "Windows 10"
                    Build = $Build
                    Version ="22H2 (2209)"
                }
            }
            elseif ($Build -eq 19046) {
                [PSCustomObject]@{
                    OS = "Windows 10"
                    Build = $Build
                    Version ="23H2 (2309)"
                }
            }
            elseif ($Build -eq 22621) {
                [PSCustomObject]@{
                    OS = "Windows 11"
                    Build = $Build
                    Version ="22H2 (2209)"
                }
            }
            elseif ($Build -eq 22631) {
                [PSCustomObject]@{
                    OS = "Windows 11"
                    Build = $Build
                    Version ="23H2 (2309)"
                }
            }
            elseif ($Build -eq 26100) {
                [PSCustomObject]@{
                    OS = "Windows 11"
                    Build = $Build
                    Version ="24H2 (2409)"
                }
            }
        }
    }
}
