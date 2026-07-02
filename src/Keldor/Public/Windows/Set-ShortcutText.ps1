function Set-ShortcutText {
<#
.SYNOPSIS
    Sets Shortcut Text.

.DESCRIPTION
    Sets Shortcut Text.

.PARAMETER Yes
    Specifies whether to enable the Yes option.

.PARAMETER No
    Specifies whether to enable the No option.

.EXAMPLE
    Set-ShortcutText
    Runs Set-ShortcutText.

.OUTPUTS
    None

.NOTES
    Author: Skyler Hart
    Created: 2020-04-18 20:44:39
    Last Edit: 2020-04-18 20:44:39
    Keywords:

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-ShortcutText
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-ShortcutText')]
    Param (
        [Switch]$Yes,
        [Switch]$No
    )

    if ($Yes) {Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name Link -Value ([byte[]](00,00,00,00)) -Force}
    elseif ($No) {Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name Link -Value ([byte[]](17,00,00,00)) -Force}
    else {Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name NoUseStoreOpenWith -Value ([byte[]](00,00,00,00)) -Force}
}
