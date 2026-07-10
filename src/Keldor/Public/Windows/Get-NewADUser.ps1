function Get-NewADUser {
    <#
.SYNOPSIS
    Gets New AD User.

.DESCRIPTION
    Gets New AD User.

.PARAMETER Days
    Specifies the Days value.

.EXAMPLE
    Get-NewADUser
    Runs Get-NewADUser.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-NewADUser
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-NewADUser')]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [int32]$Days = 1
    )

    if (Test-KeldorActiveDirectoryModule -AsBoolean -Quiet) {
        $When = ((Get-Date).AddDays(-$Days)).Date
        Get-ADUser -Filter { whenCreated -ge $When } -Properties whenCreated | Select-Object Name, SamAccountName, whenCreated
    } else {
        Write-Warning "Active Directory module is not installed and is required to run this command."
    }
}
