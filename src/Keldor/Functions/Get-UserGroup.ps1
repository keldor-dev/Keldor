function Get-UserGroup {
<#
.NOTES
    Author: Skyler Hart
    Created: 2020-11-03 11:14:26
    Last Edit: 2020-11-03 11:14:26
    Keywords:
.LINK
    https://docs.keldor.dev
#>
        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-UserGroup')]
    Param ()
$id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $groups = $id.Groups | foreach-object {$_.Translate([Security.Principal.NTAccount])}
    $groups | Select-Object Value -ExpandProperty Value
}
