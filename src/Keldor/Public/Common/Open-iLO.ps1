function Open-iLO {
<#
.SYNOPSIS
    Opens i LO.

.DESCRIPTION
    Opens i LO.

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
    Open-iLO
    Runs Open-iLO.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 02/02/2018 12:00:33
    LASTEDIT: 2020-04-17 15:36:02

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-iLO
#>





    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-iLO')]
    [Alias('iLO')]
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
    $URL = $config.iLO

    $BrowserName = $Browser
    if ($Chrome) {$BrowserName = 'Chrome'}
    elseif ($Edge) {$BrowserName = 'Edge'}
    elseif ($Firefox) {$BrowserName = 'Firefox'}
    elseif ($InternetExplorer) {$BrowserName = 'InternetExplorer'}

    Open-KeldorUrl -Uri $URL -Browser $BrowserName
}
