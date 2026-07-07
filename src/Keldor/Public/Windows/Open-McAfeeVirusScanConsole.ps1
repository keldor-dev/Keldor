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
