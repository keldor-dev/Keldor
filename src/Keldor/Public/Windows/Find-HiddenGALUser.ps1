function Find-HiddenGALUser {
    <#
.SYNOPSIS
    This function gets all users that are hidden from the GAL.

.DESCRIPTION
    This function gets all users that are hidden from the Global Address List (GAL) in a domain or you can specify an OU to search.

.PARAMETER SearchBase
    Specific OU to search. If not included, the entire domain will be searched.

.EXAMPLE
    Find-HiddenGALUsers -SearchBase "OU=Test,DC=mydomain,DC=com"
    This function gets all users that are hidden from the GAL in a domain or you can specify an OU to search.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Find-HiddenGALUser
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Find-HiddenGALUser')]
    param (
        [Parameter(
            Mandatory = $false,
            Position = 0
        )]
        [string]$SearchBase
    )

    if (Test-KeldorActiveDirectoryModule -AsBoolean -Quiet) {
        if (!([string]::IsNullOrWhiteSpace($SearchBase))) {
            Get-ADUser -Filter * -Properties givenName, Surname, SamAccountname, EmailAddress, msExchHideFromAddressLists -SearchBase $SearchBase | Where-Object { $_.msExchHideFromAddressLists -eq "TRUE" } |
                Select-Object givenName, Surname, SamAccountname, EmailAddress, msExchHideFromAddressLists
        } else {
            $sb = Get-ADDomain | Select-Object -ExpandProperty DistinguishedName
            Get-ADUser -Filter * -Properties givenName, Surname, SamAccountname, EmailAddress, msExchHideFromAddressLists -SearchBase $sb | Where-Object { $_.msExchHideFromAddressLists -eq "TRUE" } |
                Select-Object givenName, Surname, SamAccountname, EmailAddress, msExchHideFromAddressLists
        }
    } else {
        Write-Warning "Active Directory module is not installed."
    }
}
