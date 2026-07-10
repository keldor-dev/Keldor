function Open-AdminTools {
    <#
.SYNOPSIS
    Opens Admin Tools.

.DESCRIPTION
    Opens Admin Tools.

.EXAMPLE
    Open-AdminTools
    Runs Open-AdminTools.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-AdminTools
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-AdminTools')]
    [Alias('tools', 'admintools', 'admin')]
    param()
    control.exe admintools
}
