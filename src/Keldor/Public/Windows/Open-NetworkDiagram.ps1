function Open-NetworkDiagram {
<#
.SYNOPSIS
    Opens Network Diagram.

.DESCRIPTION
    Opens Network Diagram.

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
    Open-NetworkDiagram
    Runs Open-NetworkDiagram.

.OUTPUTS
    None

.NOTES
    Author: Skyler Hart
    Created: 2022-07-07 20:59:35
    Last Edit: 2022-07-07 20:59:35
    Other:
    Requires:
    -Module ActiveDirectory
    -PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
    -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-NetworkDiagram
#>





    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-NetworkDiagram')]
    [Alias('NetDiagram','NetworkDiagram')]
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
    $dpath = $config.NetDiagram

    if ($dpath -like "http*") {
        $BrowserName = $Browser
        if ($Chrome) {$BrowserName = 'Chrome'}
        elseif ($Edge) {$BrowserName = 'Edge'}
        elseif ($Firefox) {$BrowserName = 'Firefox'}
        elseif ($InternetExplorer) {$BrowserName = 'InternetExplorer'}

        Open-KeldorUrl -Uri $dpath -Browser $BrowserName
    }#is web address
    else {
        Invoke-Item $dpath
    }
}
