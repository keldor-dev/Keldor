function Open-SystemProperties {
<#
.SYNOPSIS
    Opens System Properties.

.DESCRIPTION
    Opens System Properties.

.EXAMPLE
    Open-SystemProperties
    Runs Open-SystemProperties.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-SystemProperties
#>

        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-SystemProperties')]
    Param ()
control.exe sysdm.cpl
}
