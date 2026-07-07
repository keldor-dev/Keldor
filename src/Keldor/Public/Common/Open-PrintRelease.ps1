function Open-PrintRelease {
<#
.SYNOPSIS
    Opens Print Release.

.DESCRIPTION
    Opens Print Release.

.PARAMETER Chrome
    Specifies whether to enable the Chrome option.

.PARAMETER Edge
    Specifies whether to enable the Edge option.

.PARAMETER Firefox
    Specifies whether to enable the Firefox option.

.PARAMETER InternetExplorer
    Specifies whether to enable the Internet Explorer option.

.PARAMETER Browser
    Specifies the browser to use. Valid values are Default, Edge, Chrome, Firefox, Safari, and InternetExplorer.

.EXAMPLE
    Open-PrintRelease
    Runs Open-PrintRelease.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 2022-03-08 22:02:21
    LASTEDIT: 2022-03-08 22:02:21

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-PrintRelease
#>





    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-PrintRelease')]
    Param (
        [Parameter(Mandatory=$false)]
        [Switch]$Chrome,

        [Parameter(Mandatory=$false)]
        [Switch]$Edge,

        [Parameter(Mandatory=$false)]
        [Switch]$Firefox,

        [Parameter(Mandatory=$false)]
        [Switch]$InternetExplorer,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Default','Edge','Chrome','Firefox','Safari','InternetExplorer')]
        [string]$Browser = 'Default'
    )

    $config = $Global:KeldorConfig
    $URL = $config.PrintRelease

    $BrowserName = $Browser
    if ($Chrome) {$BrowserName = 'Chrome'}
    elseif ($Edge) {$BrowserName = 'Edge'}
    elseif ($Firefox) {$BrowserName = 'Firefox'}
    elseif ($InternetExplorer) {$BrowserName = 'InternetExplorer'}

    Open-KeldorUrl -Uri $URL -Browser $BrowserName
}
