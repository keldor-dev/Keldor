function Open-ComputerManagement {
<#
.SYNOPSIS
    Opens Computer Management.

.DESCRIPTION
    Opens Computer Management.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Open-ComputerManagement
    Runs Open-ComputerManagement.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    LASTEDIT: 08/18/2017 20:48:35
    KEYWORDS:
    REQUIRES:
    #Requires -Version 3.0
    #Requires -Modules ActiveDirectory
    #Requires -PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
    #Requires -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-ComputerManagement
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-ComputerManagement')]
    Param (
        [Parameter(Mandatory=$false, Position=0)]
        [Alias('Host','Name','Computer','CN')]
        [string]$ComputerName = "$env:COMPUTERNAME"
    )
    compmgmt.msc /computer:\\$ComputerName
}
