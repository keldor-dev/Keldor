function Import-XML {
<#
.SYNOPSIS
    Imports XML.

.DESCRIPTION
    Imports XML.

.PARAMETER Path
    Specifies the path to use.

.EXAMPLE
    Import-XML -Path <value>
    Runs Import-XML.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 10/25/2017 17:03:54
    LASTEDIT: 10/25/2017 17:03:54
    KEYWORDS:

.LINK
    https://docs.keldor.dev/powershell/keldor/Import-XML
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Import-XML')]
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Path
    )

    [xml]$XmlFile = Get-Content -Path $Path
    $XmlFile
}
