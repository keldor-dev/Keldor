function Show-HiddenFiles {
    <#
.SYNOPSIS
    Shows Hidden Files.

.DESCRIPTION
    Shows Hidden Files.

.PARAMETER Yes
    Specifies whether to enable the Yes option.

.PARAMETER No
    Specifies whether to enable the No option.

.EXAMPLE
    Show-HiddenFiles
    Runs Show-HiddenFiles.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Show-HiddenFiles
#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSUseSingularNouns",
        "",
        Justification = "Expresses exactly what the function does."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Show-HiddenFiles')]
    param (
        [Switch]$Yes,
        [Switch]$No
    )

    if ($Yes) { Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Hidden -Type DWord -Value 1 -Force }
    elseif ($No) { Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Hidden -Type DWord -Value 2 -Force }
    else { Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Hidden -Type DWord -Value 1 -Force }
}
