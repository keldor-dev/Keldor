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

.LINK
    https://docs.keldor.dev/powershell/keldor/Import-DRAModule
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Import-DRAModule')]
    param ()
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
    } else {
        Write-Output "DRA module not found. Please install it from $if"
    }
}
