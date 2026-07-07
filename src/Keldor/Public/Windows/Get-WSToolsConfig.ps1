function Get-WSToolsConfig {
<#
.SYNOPSIS
    Gets WS Tools Config.

.DESCRIPTION
    Gets WS Tools Config.

.EXAMPLE
    Get-WSToolsConfig
    Runs Get-WSToolsConfig.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-WSToolsConfig
#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-WSToolsConfig')]
    [Alias('Import-WSToolsConfig','WSToolsConfig')]
    param()
    $Global:KeldorConfig
}
