function Open-LexmarkManagementConsole {
<#
.SYNOPSIS
    Opens Lexmark Management Console.

.DESCRIPTION
    Opens Lexmark Management Console.

.PARAMETER Chrome
    Specifies whether to enable the Chrome option.

.PARAMETER Edge
    Specifies whether to enable the Edge option.

.PARAMETER Firefox
    Specifies whether to enable the Firefox option.

.PARAMETER InternetExplorer
    Specifies whether to enable the Internet Explorer option.

.EXAMPLE
    Open-LexmarkManagementConsole
    Runs Open-LexmarkManagementConsole.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 2022-03-08 22:02:21
    LASTEDIT: 2022-03-08 22:02:21

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-LexmarkManagementConsole
#>





    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-LexmarkManagementConsole')]
    [Alias('lmc')]
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
    $URL = $config.LMC

    if ($Chrome) {Start-Process "chrome.exe" $URL}
    elseif ($Edge) {Start-Process Microsoft-Edge:$URL}
    elseif ($Firefox) {Start-Process "firefox.exe" $URL}
    elseif ($InternetExplorer) {Start-Process "iexplore.exe" $URL}
    else {
        #open in default browser
        (New-Object -com Shell.Application).Open($URL)
    }
}
