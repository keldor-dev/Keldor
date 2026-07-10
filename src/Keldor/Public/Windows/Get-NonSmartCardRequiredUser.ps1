function Get-NonSmartCardRequiredUser {
    <#
.SYNOPSIS
    Displays users in domain with SmartCardRequired attribute set to false.

.DESCRIPTION
    Displays all users in the domain with SmartCardRequired attribute on account set to false.

.PARAMETER Name
    Specifies the Name value.

.EXAMPLE
    Get-NonSmartCardRequiredUser
    Example of how to use this cmdlet

.OUTPUTS
    System.Array

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-NonSmartCardRequiredUser
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-NonSmartCardRequiredUser')]
    param (
        [AllowEmptyString()]
        [Alias('User')]
        [string]$Name
    )

    begin {
        $ErrorActionPreference = "Stop"
        if ($null -eq (Get-Module -ListAvailable ActiveDir*).Path) {
            throw "Active Directory module not found. Active Directory module is required to run this function."
        }
    }
    process {
        $users = Get-ADUser -Filter { SmartCardLogonRequired -eq $false } -Properties SmartCardLogonRequired, DisplayName, CanonicalName
    }
    end {
        if ($Name) {
            $users | Where-Object { $_ -match $Name }
        } else { $users }
    }
}
