function Get-ExchangeLastLoggedOnUser {
    <#
.SYNOPSIS
    Gets Exchange Last Logged On User.

.DESCRIPTION
    Gets Exchange Last Logged On User.

.EXAMPLE
    Get-ExchangeLastLoggedOnUser
    Runs Get-ExchangeLastLoggedOnUser.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-ExchangeLastLoggedOnUser
#>

    #Get-ADUser -Filter {EmailAddress -like "*"} -properties * | select EmailAddress | Export-Csv .\users.csv -NoTypeInformation
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-ExchangeLastLoggedOnUser')]
    param ()
    $userfile = ".\users.csv"
    $users = "$userfile"

    foreach ($user in $users) {
        Get-MailboxStatistics -Identity $user.EmailAddress |
            Sort-Object DisplayName | Select-Object DisplayName, LastLoggedOnUserAccount, LastLogonTime, LastLogoffTime
    }
}#end get lastloggedonuser
