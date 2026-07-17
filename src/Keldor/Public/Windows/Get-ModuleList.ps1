function Get-ModuleList {
    <#
.SYNOPSIS
    Gets locally available PowerShell modules.

.DESCRIPTION
    Returns detailed information for locally available PowerShell modules. Use NotInCommandListModules to return
    only module names that are absent from Keldor's command-list configuration.

.PARAMETER NotInCommandListModules
    Specifies whether to enable the Not In Command List Modules option.

.EXAMPLE
    Get-ModuleList

    Gets detailed information for all locally available modules.

.EXAMPLE
    Get-ModuleList -NotInCommandListModules

    Gets module names that are not listed in Keldor's CommandListModules.csv file.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-ModuleList
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-ModuleList')]
    param(
        [switch]$NotInCommandListModules
    )

    $modules = Get-Module -ListAvailable | Select-Object -Unique
    if ($NotInCommandListModules) {
        $nil = @()
        $ModuleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
        $clm = Import-Csv (Join-Path -Path $ModuleRoot -ChildPath 'CommandListModules.csv')
        $cm = $clm.Module
        foreach ($m in $modules) {
            $mn = $m.Name
            if ($cm -match $mn) {
                #do nothing
            } else {
                $nil += $mn
            }
        }

        $nil
    } else {
        $modules | Select-Object * | Sort-Object Name
    }
}
