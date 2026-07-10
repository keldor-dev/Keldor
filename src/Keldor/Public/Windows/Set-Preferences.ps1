function Set-Preferences {
    <#
.SYNOPSIS
    Sets Preferences.

.DESCRIPTION
    Sets Preferences.

.EXAMPLE
    Set-Preferences
    Runs Set-Preferences.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-Preferences
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-Preferences')]
    param ()
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    $config = $Global:KeldorConfig
    $explorer = $config.Explorer
    $store = $config.StoreLookup
    $hidden = $config.HiddenFiles
    $exten = $config.FileExtensions
    $sctext = $config.ShortcutText
    $predictionsource = $config.PSReadLinePredictionSource

    if ($explorer -eq $true) {
        if ($PSCmdlet.ShouldProcess('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\LaunchTo', "Set to 1")) {
            try {
                Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Type DWord -Value 1 -Force -ErrorAction Stop
            } catch {
                New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name Advanced -Force -ErrorAction Stop
                New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -PropertyType DWord -Value 1 -Force -ErrorAction Stop
            }
        }
    } else {
        if ($PSCmdlet.ShouldProcess('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\LaunchTo', "Set to 2")) {
            try {
                Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Type DWord -Value 2 -Force -ErrorAction Stop
            } catch {
                New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name Advanced -Force -ErrorAction Stop
                New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -PropertyType DWord -Value 2 -Force -ErrorAction Stop
            }
        }
    }

    if ($store -eq $false) {
        if ($PSCmdlet.ShouldProcess('HKCU:\Software\Policies\Microsoft\Windows\Explorer\NoUseStoreOpenWith', "Set to 1")) {
            try {
                Set-ItemProperty -Path HKCU:\Software\Policies\Microsoft\Windows\Explorer -Name NoUseStoreOpenWith -Type DWord -Value 1 -Force -ErrorAction Stop
            } catch {
                New-Item -Path HKCU:\Software\Policies\Microsoft\Windows -Name Explorer -Force -ErrorAction SilentlyContinue
                New-ItemProperty -Path HKCU:\Software\Policies\Microsoft\Windows\Explorer -Name NoUseStoreOpenWith -PropertyType DWord -Value 1 -Force -ErrorAction SilentlyContinue
            }
        }
    } else {
        if ($PSCmdlet.ShouldProcess('HKCU:\Software\Policies\Microsoft\Windows\Explorer\NoUseStoreOpenWith', "Set to 0")) {
            try {
                Set-ItemProperty -Path HKCU:\Software\Policies\Microsoft\Windows\Explorer -Name NoUseStoreOpenWith -Type DWord -Value 0 -Force -ErrorAction Stop
            } catch {
                New-Item -Path HKCU:\Software\Policies\Microsoft\Windows -Name Explorer -Force -ErrorAction Stop
                New-ItemProperty -Path HKCU:\Software\Policies\Microsoft\Windows\Explorer -Name NoUseStoreOpenWith -PropertyType DWord -Value 0 -Force -ErrorAction Stop
            }
        }
    }

    if ($hidden -eq $true) {
        if ($PSCmdlet.ShouldProcess('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Hidden', "Set to 1")) {
            try {
                Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Hidden -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
            } catch {
                New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Hidden -PropertyType DWord -Value 1 -Force -ErrorAction SilentlyContinue
            }
        }
    } else {
        if ($PSCmdlet.ShouldProcess('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Hidden', "Set to 2")) {
            try {
                Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Hidden -Type DWord -Value 2 -Force -ErrorAction SilentlyContinue
            } catch {
                New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Hidden -PropertyType DWord -Value 2 -Force -ErrorAction SilentlyContinue
            }
        }
    }

    if ($exten -eq $true) {
        if ($PSCmdlet.ShouldProcess('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideFileExt', "Set to 0")) {
            try {
                Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
            } catch {
                New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -PropertyType DWord -Value 0 -Force -ErrorAction SilentlyContinue
            }
        }
    } else {
        if ($PSCmdlet.ShouldProcess('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideFileExt', "Set to 1")) {
            try {
                Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
            } catch {
                New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -PropertyType DWord -Value 1 -Force -ErrorAction SilentlyContinue
            }
        }
    }

    if ($sctext -eq $false) {
        if ($PSCmdlet.ShouldProcess('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Link', "Set to 00,00,00,00")) {
            try {
                Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name Link -Value ([byte[]](00, 00, 00, 00)) -Force -ErrorAction SilentlyContinue
            } catch {
                New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name Link -PropertyType Binary -Value ([byte[]](00, 00, 00, 00)) -Force -ErrorAction SilentlyContinue
            }
        }
    } else {
        if ($PSCmdlet.ShouldProcess('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Link', "Set to 17,00,00,00")) {
            try {
                Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name Link -Value ([byte[]](17, 00, 00, 00)) -Force -ErrorAction SilentlyContinue
            } catch {
                New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name Link -PropertyType Binary -Value ([byte[]](17, 00, 00, 00)) -Force -ErrorAction SilentlyContinue
            }
        }
    }

    if ($PSCmdlet.ShouldProcess('PSReadLineOption', "Set PredictionSource")) {
        try {
            Set-PSReadLineOption -PredictionSource $predictionsource -ErrorAction Stop
        } catch {
            Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
        }
    }
    Write-Output "Some settings will not apply until after you log off and then log back on."
}
