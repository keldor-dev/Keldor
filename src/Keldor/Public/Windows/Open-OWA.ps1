function Open-OWA {
<#
.SYNOPSIS
    Opens OWA.

.DESCRIPTION
    Opens OWA.

.PARAMETER Chrome
    Specifies whether to enable the Chrome option.

.PARAMETER Edge
    Specifies whether to enable the Edge option.

.PARAMETER Firefox
    Specifies whether to enable the Firefox option.

.PARAMETER InternetExplorer
    Specifies whether to enable the Internet Explorer option.

.EXAMPLE
    Open-OWA
    Runs Open-OWA.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 2021-10-18 22:54:07
    LASTEDIT: 2021-10-18 22:54:48

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-OWA
#>





    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-OWA')]
    [Alias('OWA')]
    Param (
        [Parameter(Mandatory=$false)]
        [Switch]$Chrome,

        [Parameter(Mandatory=$false)]
        [Switch]$Edge,

        [Parameter(Mandatory=$false)]
        [Switch]$Firefox,

        [Parameter(Mandatory=$false)]
        [Switch]$InternetExplorer
    )

    $config = $Global:KeldorConfig
    $URL = $config.OWA

    if ($Chrome) {Start-Process "chrome.exe" $URL}
    elseif ($Edge) {Start-Process Microsoft-Edge:$URL}
    elseif ($Firefox) {Start-Process "firefox.exe" $URL}
    elseif ($InternetExplorer) {Start-Process "iexplore.exe" $URL}
    else {
        #open in default browser
        (New-Object -com Shell.Application).Open($URL)
    }
}
