function Get-KDAlias {
    <#
.SYNOPSIS
    Gets Keldor Aliases.

.DESCRIPTION
    Gets Keldor Aliases.

.EXAMPLE
    Get-KDAlias
    Runs Get-KDAlias.

.OUTPUTS
    System.Object

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 01/31/2018 23:42:55
    LASTEDIT: 07/02/2026
    KEYWORDS:

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-KDAlias
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-KDAlias')]
    [Alias('KDAliases', 'KeldorAliases')]
    param()
    Get-Alias | Where-Object { $_.Source -eq "Keldor" }
}
