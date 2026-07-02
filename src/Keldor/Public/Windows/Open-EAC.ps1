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
        [Switch]$InternetExplorer
    )

    $config = $Global:KeldorConfig
    $URL = $config.EAC

    if ($Chrome) {Start-Process "chrome.exe" $URL}
    elseif ($Edge) {Start-Process Microsoft-Edge:$URL}
    elseif ($Firefox) {Start-Process "firefox.exe" $URL}
    elseif ($InternetExplorer) {Start-Process "iexplore.exe" $URL}
    else {
        #open in default browser
        (New-Object -com Shell.Application).Open($URL)
    }
}
