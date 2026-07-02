function Add-ParamInternetBrowser {
<#
.SYNOPSIS
    Adds Param Internet Browser.

.DESCRIPTION
    Adds Param Internet Browser.

.EXAMPLE
    Add-ParamInternetBrowser
    Runs Add-ParamInternetBrowser.

.OUTPUTS
    System.Object

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 10/18/2017 12:55:22
    LASTEDIT: 10/18/2017 14:37:37
    KEYWORDS:

.LINK
    https://docs.keldor.dev/powershell/keldor/Add-ParamInternetBrowser
#>







        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Add-ParamInternetBrowser')]
    Param ()
$paramIBText = @"
        [Parameter(Mandatory=`$false)]
        [Switch]`$Chrome,

        [Parameter(Mandatory=`$false)]
        [Switch]`$Edge,

        [Parameter(Mandatory=`$false)]
        [Switch]`$Firefox,

        [Parameter(Mandatory=`$false)]
        [Switch]`$InternetExplorer
"@
    $psise.CurrentFile.Editor.InsertText($paramIBText)
}
