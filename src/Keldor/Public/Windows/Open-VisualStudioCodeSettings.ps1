function Open-VisualStudioCodeSettings {
<#
.SYNOPSIS
    Opens Visual Studio Code Settings.

.DESCRIPTION
    Opens Visual Studio Code Settings.

.EXAMPLE
    Open-VisualStudioCodeSettings
    Runs Open-VisualStudioCodeSettings.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-VisualStudioCodeSettings
#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSUseSingularNouns",
        "",
        Justification = "Expresses exactly what the function does."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-VisualStudioCodeSettings')]
    [Alias('Open-VSCCodeSettings')]
    param()

    $vssettings = "$env:APPDATA\Code\User\settings.json"
    if ($host.Name -match "Visual Studio Code") {
        code $vssettings
    }
    else {
        powershell_ise $vssettings
    }
}
