function Open-HIPSLog {
<#
.SYNOPSIS
    Opens HIPS Log.

.DESCRIPTION
    Opens HIPS Log.

.EXAMPLE
    Open-HIPSLog
    Runs Open-HIPSLog.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-HIPSLog
#>

        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-HIPSLog')]
    Param ()
explorer "$env:ProgramData\McAfee\Host Intrusion Prevention"
}
