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

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-ShortcutText
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-ShortcutText')]
    param (
        [Switch]$Yes,
        [Switch]$No
    )

    if ($Yes) {
        if ($PSCmdlet.ShouldProcess('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Link', "Set shortcut text on")) {
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name Link -Value ([byte[]](00, 00, 00, 00)) -Force
        }
    } elseif ($No) {
        if ($PSCmdlet.ShouldProcess('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Link', "Set shortcut text off")) {
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name Link -Value ([byte[]](17, 00, 00, 00)) -Force
        }
    } else {
        if ($PSCmdlet.ShouldProcess('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\NoUseStoreOpenWith', "Set NoUseStoreOpenWith")) {
            Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name NoUseStoreOpenWith -Value ([byte[]](00, 00, 00, 00)) -Force
        }
    }
}
