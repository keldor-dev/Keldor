function Get-ProtectedGroup {
<#
.SYNOPSIS
    Gets Protected Group.

.DESCRIPTION
    Gets Protected Group.

.EXAMPLE
    Get-ProtectedGroup
    Runs Get-ProtectedGroup.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-ProtectedGroup
#>

        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-ProtectedGroup')]
    Param ()
if (Get-Module -ListAvailable -Name ActiveDirectory) {
        $groups = (Get-ADGroup -filter {admincount -eq "1"}).Name | Sort-Object
        $groups
    }
    else {
        Write-Warning "Active Directory module is not installed and is required to run this command."
    }
}
