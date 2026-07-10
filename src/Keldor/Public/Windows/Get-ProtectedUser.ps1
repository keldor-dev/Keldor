function Get-ProtectedUser {
    <#
.SYNOPSIS
    Gets Protected User.

.DESCRIPTION
    Gets Protected User.

.EXAMPLE
    Get-ProtectedUser
    Runs Get-ProtectedUser.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-ProtectedUser
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-ProtectedUser')]
    param ()
    if (Get-Module -ListAvailable -Name ActiveDirectory) {
        $users = (Get-ADUser -filter { admincount -eq "1" }).Name | Sort-Object
        $users
    } else {
        Write-Warning "Active Directory module is not installed and is required to run this command."
    }
}
