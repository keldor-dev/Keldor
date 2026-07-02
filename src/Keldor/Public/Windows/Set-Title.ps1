function Set-Title {
<#
.SYNOPSIS
    Sets Title.

.DESCRIPTION
    Sets Title.

.PARAMETER titleText
    Specifies the title Text value.

.EXAMPLE
    Set-Title -titleText <value>
    Runs Set-Title.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    LASTEDIT: 08/18/2017 20:47:14
    KEYWORDS:

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-Title
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-Title')]
    [Alias('title')]
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$titleText
    )
    $Host.UI.RawUI.WindowTitle = $titleText
}
