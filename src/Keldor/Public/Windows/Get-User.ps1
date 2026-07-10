function Get-User {
    <#
.SYNOPSIS
    Gets User.

.DESCRIPTION
    Gets User.

.PARAMETER ComputerName
    Specifies the computer name to use.

.PARAMETER User
    Specifies the User value.

.EXAMPLE
    Get-User
    Runs Get-User.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-User
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-User')]
    param(
        [Parameter(
            Mandatory = $false,
            Position = 0
        )]
        [ValidateNotNullorEmpty()]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME",

        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [Alias('Username')]
        [string]$User
    )

    foreach ($Comp in $ComputerName) {
        try {
            #Connect to computer and get information on user/users
            if ($null -ne $User) {
                $ui = Get-WmiObject -Class Win32_UserAccount -filter "LocalAccount='True'" -ComputerName $comp -ErrorAction Stop | Select-Object Name, Description, Disabled, Lockout, PasswordChangeable, PasswordExpires, PasswordRequired | Where-Object { $_.Name -match $User }
            }#if user not null
            else {
                $ui = Get-WmiObject -Class Win32_UserAccount -filter "LocalAccount='True'" -ComputerName $comp -ErrorAction Stop | Select-Object Name, Description, Disabled, Lockout, PasswordChangeable, PasswordExpires, PasswordRequired
            }

            foreach ($u in $ui) {
                [PSCustomObject]@{
                    Computer           = $Comp
                    User               = $u.Name
                    Description        = $u.Description
                    Disabled           = $u.Disabled
                    Locked             = $u.Lockout
                    PasswordChangeable = $u.PasswordChangeable
                    PasswordExpires    = $u.PasswordExpires
                    PasswordRequired   = $u.PasswordRequired
                }
            }#foreach u
        }#try
        catch {
            [PSCustomObject]@{
                Computer           = $Comp
                User               = $null
                Description        = $null
                Disabled           = $null
                Locked             = $null
                PasswordChangeable = $null
                PasswordExpires    = $null
                PasswordRequired   = $null
            }
        }#catch
    }#foreach comp
}
