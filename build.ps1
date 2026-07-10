[CmdletBinding()]
param(
    [ValidateSet('Validate', 'Build', 'Release', 'Publish')]
    [string]$Task = 'Build',

    [string]$Version,

    [string]$Repository = 'PSGallery',

    [string]$NuGetApiKey
)

$ErrorActionPreference = 'Stop'
$script:KeldorBuildScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Get-KeldorRepositoryRoot {
    $script:KeldorBuildScriptRoot
}

function Test-KeldorSemanticVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Version
    )

    $pattern = '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9A-Za-z-][0-9A-Za-z-]*)(?:\.(?:0|[1-9A-Za-z-][0-9A-Za-z-]*))*))?$'
    return $Version -match $pattern
}

function Split-KeldorSemanticVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Version
    )

    if (-not (Test-KeldorSemanticVersion -Version $Version)) {
        throw "Version '$Version' is not a valid semantic version. Use MAJOR.MINOR.PATCH or MAJOR.MINOR.PATCH-prerelease."
    }

    $parts = $Version -split '-', 2
    [pscustomobject]@{
        ModuleVersion = $parts[0]
        Prerelease    = if ($parts.Count -gt 1) { $parts[1] } else { $null }
    }
}

function Update-KeldorManifestVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ManifestPath,

        [Parameter(Mandatory)]
        [string]$Version
    )

    $versionParts = Split-KeldorSemanticVersion -Version $Version
    $content = Get-Content -Path $ManifestPath -Raw
    $content = $content -replace "(?m)^(\s*ModuleVersion\s*=\s*)'[^']+'", "`$1'$($versionParts.ModuleVersion)'"

    if ($versionParts.Prerelease) {
        if ($content -match "(?m)^\s*#\s*Prerelease\s*=\s*''") {
            $content = $content -replace "(?m)^(\s*)#\s*Prerelease\s*=\s*''", "`$1Prerelease = '$($versionParts.Prerelease)'"
        } elseif ($content -match "(?m)^\s*Prerelease\s*=") {
            $content = $content -replace "(?m)^(\s*Prerelease\s*=\s*)'[^']*'", "`$1'$($versionParts.Prerelease)'"
        } else {
            $content = $content -replace "(?m)^(\s*ReleaseNotes\s*=\s*@\()", "            Prerelease = '$($versionParts.Prerelease)'`n`$1"
        }
    } else {
        $content = $content -replace "(?m)^(\s*)Prerelease\s*=\s*'[^']*'", "`$1# Prerelease = ''"
    }

    Set-Content -Path $ManifestPath -Value $content -NoNewline
}

function Test-KeldorManifestVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ManifestPath,

        [string]$ExpectedVersion
    )

    $manifest = Test-ModuleManifest -Path $ManifestPath
    $manifestVersion = $manifest.Version.ToString()

    if (-not (Test-KeldorSemanticVersion -Version $manifestVersion)) {
        throw "Manifest version '$manifestVersion' is not a valid semantic version."
    }

    if ($ExpectedVersion -and $manifestVersion -ne $ExpectedVersion) {
        throw "Manifest version '$manifestVersion' does not match expected version '$ExpectedVersion'."
    }

    return $manifest
}

function Copy-KeldorModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SourceModulePath,

        [Parameter(Mandatory)]
        [string]$DestinationModulePath
    )

    if (Test-Path -Path $DestinationModulePath) {
        Remove-Item -Path $DestinationModulePath -Recurse -Force
    }

    $destinationRoot = Split-Path -Parent $DestinationModulePath
    New-Item -Path $destinationRoot -ItemType Directory -Force | Out-Null
    Copy-Item -Path $SourceModulePath -Destination $DestinationModulePath -Recurse -Force
}

function Assert-KeldorPublishVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Version,

        [Parameter(Mandatory)]
        [string]$Repository
    )

    if (-not (Get-Command -Name Find-Module -ErrorAction SilentlyContinue)) {
        Write-Warning 'Find-Module is not available; skipping repository version comparison.'
        return
    }

    $latest = Find-Module -Name Keldor -Repository $Repository -ErrorAction SilentlyContinue
    if (-not $latest) {
        return
    }

    $requested = Split-KeldorSemanticVersion -Version $Version
    $requestedVersion = [version]$requested.ModuleVersion
    $latestVersion = [version]$latest.Version

    if ($requestedVersion -le $latestVersion) {
        throw "Requested version '$Version' must be greater than latest '$($latest.Version)' in repository '$Repository'."
    }
}

function Invoke-KeldorBuild {
    [CmdletBinding()]
    param(
        [ValidateSet('Validate', 'Build', 'Release', 'Publish')]
        [string]$Task = 'Build',

        [string]$Version,

        [string]$Repository = 'PSGallery',

        [string]$NuGetApiKey
    )

    $repoRoot = Get-KeldorRepositoryRoot
    $sourceModule = Join-Path -Path $repoRoot -ChildPath 'src/Keldor'
    $sourceManifest = Join-Path -Path $sourceModule -ChildPath 'Keldor.psd1'
    $buildRoot = Join-Path -Path $repoRoot -ChildPath 'out'
    $buildModule = Join-Path -Path $buildRoot -ChildPath 'Keldor'
    $buildManifest = Join-Path -Path $buildModule -ChildPath 'Keldor.psd1'

    switch ($Task) {
        'Validate' {
            Test-KeldorManifestVersion -ManifestPath $sourceManifest -ExpectedVersion '0.1.0' | Out-Null
            Write-Host "Validated Keldor source manifest version 0.1.0."
        }

        'Build' {
            Test-KeldorManifestVersion -ManifestPath $sourceManifest | Out-Null
            Copy-KeldorModule -SourceModulePath $sourceModule -DestinationModulePath $buildModule
            Test-KeldorManifestVersion -ManifestPath $buildManifest | Out-Null
            Write-Host "Built Keldor module at '$buildModule'."
        }

        'Release' {
            if (-not $Version) {
                throw 'Release requires -Version.'
            }

            $versionParts = Split-KeldorSemanticVersion -Version $Version
            Test-KeldorManifestVersion -ManifestPath $sourceManifest | Out-Null
            Copy-KeldorModule -SourceModulePath $sourceModule -DestinationModulePath $buildModule
            Update-KeldorManifestVersion -ManifestPath $buildManifest -Version $Version
            Test-KeldorManifestVersion -ManifestPath $buildManifest -ExpectedVersion $versionParts.ModuleVersion | Out-Null
            Write-Host "Prepared Keldor release package version '$Version' at '$buildModule'."
        }

        'Publish' {
            if (-not $Version) {
                throw 'Publish requires -Version.'
            }

            Assert-KeldorPublishVersion -Version $Version -Repository $Repository
            Invoke-KeldorBuild -Task Release -Version $Version -Repository $Repository

            $publishParameters = @{
                Path       = $buildModule
                Repository = $Repository
            }

            if ($NuGetApiKey) {
                $publishParameters.NuGetApiKey = $NuGetApiKey
            }

            Publish-Module @publishParameters
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    Invoke-KeldorBuild @PSBoundParameters
}
