function Get-UserGroup {
    <#
.SYNOPSIS
    Gets User Group.

.DESCRIPTION
    Gets User Group.

.EXAMPLE
    Get-UserGroup
    Runs Get-UserGroup.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-UserGroup
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-UserGroup')]
    param ()
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $groups = $id.Groups | ForEach-Object { $_.Translate([Security.Principal.NTAccount]) }
    $groups | Select-Object Value -ExpandProperty Value
}
