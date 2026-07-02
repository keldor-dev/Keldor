function Get-WSToolsAlias {
<#
.SYNOPSIS
    Gets WS Tools Alias.

.DESCRIPTION
    Gets WS Tools Alias.

.EXAMPLE
    Get-WSToolsAlias
    Runs Get-WSToolsAlias.

.OUTPUTS
    System.Object

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 01/31/2018 23:42:55
    LASTEDIT: 01/31/2018 23:42:55
    KEYWORDS:

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-WSToolsAlias
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-WSToolsAlias')]
    [Alias('WSToolsAliases')]
    param()
    Get-Alias | Where-Object {$_.Source -eq "Keldor"}
}
