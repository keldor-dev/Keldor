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

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 02/05/2018 17:26:06
    LASTEDIT: 2022-09-04 02:32:23
    KEYWORDS:
    REQUIRES:
    -Modules ActiveDirectory

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-ProtectedUser
#>





        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-ProtectedUser')]
    Param ()
if (Get-Module -ListAvailable -Name ActiveDirectory) {
        $users = (Get-ADUser -filter {admincount -eq "1"}).Name | Sort-Object
        $users
    }
    else {
        Write-Warning "Active Directory module is not installed and is required to run this command."
    }
}
