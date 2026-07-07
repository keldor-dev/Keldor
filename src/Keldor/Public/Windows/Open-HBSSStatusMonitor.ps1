function Open-HBSSStatusMonitor {
<#
.SYNOPSIS
    Opens HBSS Status Monitor.

.DESCRIPTION
    Opens HBSS Status Monitor.

.EXAMPLE
    Open-HBSSStatusMonitor
    Runs Open-HBSSStatusMonitor.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-HBSSStatusMonitor
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-HBSSStatusMonitor')]
    [Alias('HBSS')]
    param()
    if (Test-Path "$env:ProgramFiles\McAfee\Agent\cmdagent.exe") {
        Start-Process "$env:ProgramFiles\McAfee\Agent\cmdagent.exe" /s
    }
    elseif (Test-Path "$env:ProgramFiles\McAfee\Common Framework\CmdAgent.exe") {
        Start-Process "$env:ProgramFiles\McAfee\Common Framework\CmdAgent.exe" /s
    }
    elseif (Test-Path "${env:ProgramFiles(x86)}\McAfee\Common Framework\CmdAgent.exe") {
        Start-Process "${env:ProgramFiles(x86)}\McAfee\Common Framework\CmdAgent.exe" /s
    }
    else {
       Throw "HBSS Client Agent not found"
    }
}
