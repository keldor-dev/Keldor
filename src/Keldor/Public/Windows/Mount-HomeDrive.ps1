function Mount-HomeDrive {
    <#
.SYNOPSIS
    Mounts Home Drive.

.DESCRIPTION
    Mounts Home Drive.

.EXAMPLE
    Mount-HomeDrive
    Runs Mount-HomeDrive.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Mount-HomeDrive
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Mount-HomeDrive')]
    [Alias('Add-HomeDrive')]
    param()
    net use $env:HOMEDRIVE $env:HOMESHARE /persistent:yes
}
