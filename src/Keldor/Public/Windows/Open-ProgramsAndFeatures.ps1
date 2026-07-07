function Open-ProgramsAndFeatures {
<#
.SYNOPSIS
    Opens Programs And Features.

.DESCRIPTION
    Opens Programs And Features.

.EXAMPLE
    Open-ProgramsAndFeatures
    Runs Open-ProgramsAndFeatures.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-ProgramsAndFeatures
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-ProgramsAndFeatures')]
    [Alias('programs')]
    param()
    Start-Process appwiz.cpl
}
