function Open-SharedFolders {
<#
.SYNOPSIS
    Opens Shared Folders.

.DESCRIPTION
    Opens Shared Folders.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Open-SharedFolders
    Runs Open-SharedFolders.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 08/19/2017 22:14:08
    LASTEDIT: 08/19/2017 22:14:08
    KEYWORDS:
    REQUIRES:
    -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-SharedFolders
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-SharedFolders')]
    [Alias('Shares','Get-Shares')]
    Param (
        [Parameter(Mandatory=$false, Position=0)]
        [Alias('Host','Name','Computer','CN')]
        [string]$ComputerName = "$env:COMPUTERNAME"
    )
    fsmgmt.msc /computer=\\$ComputerName
}
