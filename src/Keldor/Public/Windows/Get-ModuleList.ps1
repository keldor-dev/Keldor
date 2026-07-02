function Get-ModuleList {
<#
.SYNOPSIS
    Short description

.DESCRIPTION
    Long description

.PARAMETER NotInCommandListModules
    Specifies whether to enable the Not In Command List Modules option.

.EXAMPLE
    Get-ModuleList
    Example of how to use this cmdlet

.EXAMPLE
    Get-ModuleList -PARAMETER
    Another example of how to use this cmdlet but with a parameter or switch.

.OUTPUTS
    System.Object

.NOTES
    Author: Skyler Hart
    Created: 2021-08-11 23:22:30
    Last Edit: 2021-08-11 23:41:15
    Keywords:
    Other:
    Requires:
        -Module ActiveDirectory
        -PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
        -RunAsAdministrator

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
            }
            else {
                $nil += $mn
            }
        }

        $nil
    }
    else {
        $modules | Select-Object * | Sort-Object Name
    }
}
