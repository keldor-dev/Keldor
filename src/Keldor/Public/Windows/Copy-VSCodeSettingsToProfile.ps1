function Copy-VSCodeSettingsToProfile {
<#
.SYNOPSIS
    Copies Visual Studio Code settings to the user's profile.

.DESCRIPTION
    This function copies Visual Studio Code settings from a configured repository path to the user's profile, ensuring the settings are up-to-date.

.EXAMPLE
    Copy-VSCodeSettingsToProfile
    Copies the VSCode settings from the configured repository path to the user's profile settings.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 2021-11-01 22:14:14
    LASTEDIT: 2024-11-27 13:00:00

.LINK
    https://docs.keldor.dev/powershell/keldor/Copy-VSCodeSettingsToProfile
#>







    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Copy-VSCodeSettingsToProfile')]
    param ()

    $vscs = ($Global:KeldorConfig).VSCodeSettingsPath
    $userSettingsPath = "$env:APPDATA\Code\User\settings.json"

    if (-not (Test-Path -Path "$env:APPDATA\Code\User")) {
        New-Item -Path "$env:APPDATA\Code" -ItemType Directory -Name "User" -Force | Out-Null
    }

    $settingsContent = Get-Content -Path $vscs -Raw

    if (Test-Path -Path $userSettingsPath) {
        Set-Content -Path $userSettingsPath -Value $settingsContent -Force
    } else {
        Add-Content -Path $userSettingsPath -Value $settingsContent -Force
    }
}
