function Import-DRAModule {
<#
.SYNOPSIS
    Imports DRA Module.

.DESCRIPTION
    Imports DRA Module.

.EXAMPLE
    Import-DRAModule
    Runs Import-DRAModule.

.OUTPUTS
    System.Object

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 10/17/2019 13:47:31
    LASTEDIT: 2020-08-20 14:42:59
    KEYWORDS:

.LINK
    https://docs.keldor.dev/powershell/keldor/Import-DRAModule
#>





        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Import-DRAModule')]
    Param ()
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    $config = $Global:KeldorConfig
    $ip = $config.DRAInstallLocation
    $if = $config.DRAInstallFile

    if (Test-Path $ip) {
        Import-Module $ip
    }
    else {
        Write-Output "DRA module not found. Please install it from $if"
    }
}
