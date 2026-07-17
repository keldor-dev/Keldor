#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter()]
    [ValidateSet('Validate', 'Build', 'Release', 'Publish')]
    [string]$Task = 'Build',

    [Parameter()]
    [string]$Version,

    [Parameter()]
    [string]$Repository = 'PSGallery',

    [Parameter()]
    [string]$NuGetApiKey,

    [Parameter()]
    [string]$BuildModulePath
)

$ErrorActionPreference = 'Stop'
$RequiredBuildModuleVersion = [version]'0.2.0'
$ConfigurationPath = Join-Path -Path $PSScriptRoot -ChildPath 'build.config.psd1'

if ($BuildModulePath) {
    $ResolvedBuildModulePath = (Resolve-Path -LiteralPath $BuildModulePath -ErrorAction Stop).Path

    if (Test-Path -LiteralPath $ResolvedBuildModulePath -PathType Container) {
        $ResolvedBuildModulePath = Join-Path `
            -Path $ResolvedBuildModulePath `
            -ChildPath 'Keldor.Build.PowerShell.psd1'
    }

    Import-Module -Name $ResolvedBuildModulePath -Force -ErrorAction Stop
} else {
    $AvailableBuildModule = Get-Module -ListAvailable -Name Keldor.Build.PowerShell |
        Where-Object { $_.Version -eq $RequiredBuildModuleVersion } |
        Select-Object -First 1

    if (-not $AvailableBuildModule) {
        throw "Keldor.Build.PowerShell $RequiredBuildModuleVersion is required. Install that exact version or pass " +
            '-BuildModulePath for an explicit local development override.'
    }

    Import-Module `
        -Name Keldor.Build.PowerShell `
        -RequiredVersion $RequiredBuildModuleVersion `
        -ErrorAction Stop
}

$ImportedBuildModule = Get-Module -Name Keldor.Build.PowerShell | Select-Object -First 1

if (-not $ImportedBuildModule -or $ImportedBuildModule.Version -ne $RequiredBuildModuleVersion) {
    throw "Keldor.Build.PowerShell $RequiredBuildModuleVersion is required; imported version was " +
        "'$($ImportedBuildModule.Version)'."
}

$BuildParameters = @{
    ConfigurationPath = $ConfigurationPath
    Task              = $Task
    Repository        = $Repository
}

if ($Version) {
    $BuildParameters.Version = $Version
}

if ($NuGetApiKey) {
    $BuildParameters.NuGetApiKey = $NuGetApiKey
}

Invoke-KeldorPowerShellBuild @BuildParameters -WhatIf:$WhatIfPreference -Confirm:$false
