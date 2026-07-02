function Get-ProtectedGroup {
<#
.Notes
    AUTHOR: Skyler Hart
    CREATED: 02/05/2018 17:24:35
    LASTEDIT: 2022-09-04 02:30:15
    KEYWORDS:
    REQUIRES:
        -Modules ActiveDirectory
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
