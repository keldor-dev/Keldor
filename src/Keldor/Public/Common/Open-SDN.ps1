function Open-SDN {
<#
.SYNOPSIS
    Opens SDN.

.DESCRIPTION
    Opens SDN.

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
    Open-SDN
    Runs Open-SDN.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 2021-10-18 22:38:19
    LASTEDIT: 2021-10-18 22:39:28

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-SDN
#>





    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-SDN')]
    [Alias('Open-SDNMgmt','SDN','Open-Unifi','unifi')]
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
    $URL = $config.SDNMgmt

    $BrowserName = $Browser
    if ($Chrome) {$BrowserName = 'Chrome'}
    elseif ($Edge) {$BrowserName = 'Edge'}
    elseif ($Firefox) {$BrowserName = 'Firefox'}
    elseif ($InternetExplorer) {$BrowserName = 'InternetExplorer'}

    Open-KeldorUrl -Uri $URL -Browser $BrowserName
}
