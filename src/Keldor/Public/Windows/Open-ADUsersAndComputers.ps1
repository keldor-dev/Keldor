function Open-ADUsersAndComputers {
<#
.SYNOPSIS
    Opens AD Users And Computers.

.DESCRIPTION
    Opens AD Users And Computers.

.EXAMPLE
    Open-ADUsersAndComputers
    Runs Open-ADUsersAndComputers.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-ADUsersAndComputers
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-ADUsersAndComputers')]
    [Alias('aduc','dsa')]
    param()
    try {
        $ErrorActionPreference = "Stop"
        dsa.msc
    }
    catch {
        Write-Output "Active Directory snapins are not installed/enabled."
    }
}
