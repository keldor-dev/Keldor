function Get-FunctionsInModule {
    <#
.SYNOPSIS
    Gets Functions In Module.

.DESCRIPTION
    Gets Functions In Module.

.PARAMETER Module
    Specifies the Module value.

.EXAMPLE
    Get-FunctionsInModule -Module <value>
    Runs Get-FunctionsInModule.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-FunctionsInModule
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-FunctionsInModule')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Module
    )

    $mod = (Get-Module $Module -ListAvailable).ExportedCommands
    $mod.Values.Name | Sort-Object
}
