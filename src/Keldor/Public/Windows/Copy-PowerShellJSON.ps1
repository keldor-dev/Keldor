function Copy-PowerShellJSON {
<#
.SYNOPSIS
    Enables PowerShell Snippets in Visual Studio Code.

.DESCRIPTION
    Copies the powershell.json file from the Keldor module folder to %AppData%\Roaming\Code\User\snippets for the currently logged on user.

.EXAMPLE
    Copy-PowerShellJSON
    Copies the powershell.json file from the Keldor module folder to %AppData%\Roaming\Code\User\snippets for the currently logged on user.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Copy-PowerShellJSON
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Copy-PowerShellJSON')]
    [Alias('Update-PowerShellJSON','Set-PowerShellJSON')]
    param()

    if (!(Test-Path $env:APPDATA\Code\User)) {
        New-Item -Path $env:APPDATA\Code -ItemType Directory -Name User -Force
    }
    if (!(Test-Path $env:APPDATA\Code\User\snippets)) {
        New-Item -Path $env:APPDATA\Code\User -ItemType Directory -Name snippets -Force
    }
    $ModuleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    Copy-Item -Path (Join-Path -Path $ModuleRoot -ChildPath 'powershell.json') -Destination $env:APPDATA\Code\User\snippets\powershell.json -Force
}
