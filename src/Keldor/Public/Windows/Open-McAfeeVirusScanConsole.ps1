function Open-McAfeeVirusScanConsole {
<#
.SYNOPSIS
    Opens Mc Afee Virus Scan Console.

.DESCRIPTION
    Opens Mc Afee Virus Scan Console.

.EXAMPLE
    Open-McAfeeVirusScanConsole
    Runs Open-McAfeeVirusScanConsole.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    CREATED: Sometime before 8/7/2017
    LASTEDIT: 08/18/2017 21:11:16
    KEYWORDS:
    REQUIRES:
    #Requires -Version 3.0
    #Requires -Modules ActiveDirectory
    #Requires -PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
    #Requires -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-McAfeeVirusScanConsole
#>





        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-McAfeeVirusScanConsole')]
    Param ()
if (Test-Path "$env:ProgramFiles\McAfee\VirusScan Enterprise\mcconsol.exe") {
        Start-Process "$env:ProgramFiles\McAfee\VirusScan Enterprise\mcconsol.exe"
    }
    else {Start-Process "${env:ProgramFiles(x86)}\McAfee\VirusScan Enterprise\mcconsol.exe"}
}
