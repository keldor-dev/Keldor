function Show-FileExtensions {
<#
.SYNOPSIS
    Shows File Extensions.

.DESCRIPTION
    Shows File Extensions.

.PARAMETER Yes
    Specifies whether to enable the Yes option.

.PARAMETER No
    Specifies whether to enable the No option.

.EXAMPLE
    Show-FileExtensions
    Runs Show-FileExtensions.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Show-FileExtensions
#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSUseSingularNouns",
        "",
        Justification = "Expresses exactly what the function does."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Show-FileExtensions')]
    Param (
        [Switch]$Yes,
        [Switch]$No
    )

    if ($Yes) {Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -Type DWord -Value 0 -Force}
    elseif ($No) {Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -Type DWord -Value 1 -Force}
    else {Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -Type DWord -Value 0 -Force}
}
