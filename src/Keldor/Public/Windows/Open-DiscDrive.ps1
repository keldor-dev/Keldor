function Open-DiscDrive {
    <#
.SYNOPSIS
    Opens Disc Drive.

.DESCRIPTION
    Opens Disc Drive.

.EXAMPLE
    Open-DiscDrive
    Runs Open-DiscDrive.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-DiscDrive
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-DiscDrive')]
    [Alias('Eject-Disc')]
    param()
    $sh = New-Object -ComObject "Shell.Application"
    $sh.Namespace(17).Items() | Where-Object { $_.Type -eq "CD Drive" } | ForEach-Object { $_.InvokeVerb("Eject") }
}
