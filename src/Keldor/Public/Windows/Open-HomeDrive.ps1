function Open-HomeDrive {
    <#
.SYNOPSIS
    Opens Home Drive.

.DESCRIPTION
    Opens Home Drive.

.EXAMPLE
    Open-HomeDrive
    Runs Open-HomeDrive.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-HomeDrive
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-HomeDrive')]
    param ()
    explorer.exe $env:HOMESHARE
}
