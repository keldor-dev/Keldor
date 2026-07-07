function Get-FSMO {
<#
.SYNOPSIS
    Gets FSMO.

.DESCRIPTION
    Gets FSMO.

.PARAMETER netdom
    Specifies whether to enable the netdom option.

.EXAMPLE
    Get-FSMO
    Runs Get-FSMO.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-FSMO
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-FSMO')]
    [Alias('fsmo')]
    Param (
        [Parameter()]
        [Switch]$netdom
    )
    if (!$netdom) {
        if (Get-Module -ListAvailable -Name ActiveDirectory) {
            $RoleHolders = Get-ADDomainController -Filter * | Select-Object Name,OperationMasterRoles
            $RoleHolderInfo = foreach ($RoleHolder in $RoleHolders) {
                $Comp = $RoleHolder.Name
                $Roles = $RoleHolder.OperationMasterRoles
                $Roles = $Roles -join ", "
                [PSCustomObject]@{
                    ComputerName = $Comp
                    Roles = $Roles
                }#new object
            }
            $RoleHolderInfo
        }
        else {
            netdom /query FSMO
        }
    }
    else {
        netdom /query FSMO
    }
}
