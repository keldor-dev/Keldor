function Open-EAC {
<#
.SYNOPSIS
    Opens EAC.

.DESCRIPTION
    Opens EAC.

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
    Open-EAC
    Runs Open-EAC.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 2021-10-18 22:55:39
    LASTEDIT: 2021-10-18 22:56:47

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-EAC
#>





    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-EAC')]
    [Alias('Open-ECP','EAC','ECP')]
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
    $URL = $config.EAC

    $BrowserName = $Browser
    if ($Chrome) {$BrowserName = 'Chrome'}
    elseif ($Edge) {$BrowserName = 'Edge'}
    elseif ($Firefox) {$BrowserName = 'Firefox'}
    elseif ($InternetExplorer) {$BrowserName = 'InternetExplorer'}

    Open-KeldorUrl -Uri $URL -Browser $BrowserName
}
