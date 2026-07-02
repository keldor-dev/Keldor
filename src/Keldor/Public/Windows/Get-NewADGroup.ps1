function Get-NewADGroup {
<#
.SYNOPSIS
    Gets New AD Group.

.DESCRIPTION
    Gets New AD Group.

.PARAMETER Days
    Specifies the Days value.

.EXAMPLE
    Get-NewADGroup
    Runs Get-NewADGroup.

.OUTPUTS
    System.Object

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 08/18/2017 02:34:40
    LASTEDIT: 2022-09-01 23:05:07
    KEYWORDS:
    REQUIRES:
    -Modules ActiveDirectory

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-NewADGroup
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-NewADGroup')]
    Param (
        [Parameter(Mandatory=$false, Position=0)]
        [int32]$Days = 1
    )

    if (Get-Module -ListAvailable -Name ActiveDirectory) {
        $When = ((Get-Date).AddDays(-$Days)).Date
        Get-ADGroup -Filter {whenCreated -ge $When} -Properties whenCreated | Select-Object Name,SamAccountName,whenCreated
    }
    else {
        Write-Warning "Active Directory module is not installed and is required to run this command."
    }
}
