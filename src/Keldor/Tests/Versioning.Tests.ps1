Describe "Keldor versioning" {
    BeforeAll {
        $script:ModuleRoot = Split-Path -Parent $PSScriptRoot
        $script:RepoRoot = Split-Path -Parent (Split-Path -Parent $script:ModuleRoot)
        $script:ManifestPath = Join-Path $script:ModuleRoot 'Keldor.psd1'
        $script:BuildScript = Join-Path $script:RepoRoot 'build.ps1'
        $script:LocalBuildModulePath = $env:KELDOR_BUILD_MODULE_PATH

        function Invoke-KeldorVersioningBuild {
            param(
                [Parameter(Mandatory)]
                [string]$Task,

                [Parameter()]
                [string]$Version
            )

            $BuildParameters = @{
                Task        = $Task
                ErrorAction = 'Stop'
            }

            if ($Version) {
                $BuildParameters.Version = $Version
            }

            if ($script:LocalBuildModulePath) {
                $BuildParameters.BuildModulePath = $script:LocalBuildModulePath
            }

            & $script:BuildScript @BuildParameters
        }
    }

    It "uses 0.1.0 as the authoritative source manifest version" {
        $manifest = Test-ModuleManifest -Path $script:ManifestPath

        $manifest.Version.ToString() | Should -Be '0.1.0'
    }

    It "validates semantic versions and prerelease versions" {
        { Invoke-KeldorVersioningBuild -Task Release -Version '1.1' } |
            Should -Throw '*not a valid semantic version*'
        { Invoke-KeldorVersioningBuild -Task Release -Version '1.1.0.0' } |
            Should -Throw '*not a valid semantic version*'
    }

    It "normal builds leave the source manifest unchanged" {
        $before = Get-Content -Path $script:ManifestPath -Raw

        Invoke-KeldorVersioningBuild -Task Build | Out-Null

        $after = Get-Content -Path $script:ManifestPath -Raw
        $after | Should -Be $before
    }

    It "injects release versions into the packaged manifest only" {
        Invoke-KeldorVersioningBuild -Task Release -Version '1.1.0-preview.1' | Out-Null

        $builtManifestPath = Join-Path $script:RepoRoot 'out/Keldor/Keldor.psd1'
        $builtManifest = Import-PowerShellDataFile -Path $builtManifestPath
        $sourceManifest = Test-ModuleManifest -Path $script:ManifestPath

        $builtManifest.ModuleVersion | Should -Be '1.1.0'
        $builtManifest.PrivateData.PSData.Prerelease | Should -Be 'preview.1'
        $sourceManifest.Version.ToString() | Should -Be '0.1.0'
    }

    It 'writes explicit function exports into packaged manifests' {
        Invoke-KeldorVersioningBuild -Task Build | Out-Null

        $builtManifestPath = Join-Path $script:RepoRoot 'out/Keldor/Keldor.psd1'
        $builtManifest = Import-PowerShellDataFile -Path $builtManifestPath
        $expectedFunctions = Get-ChildItem (Join-Path $script:ModuleRoot 'Public') -Filter '*.ps1' -File -Recurse |
            Select-Object -ExpandProperty BaseName |
            Sort-Object -Unique

        $builtManifest.FunctionsToExport | Should -Not -Contain '*'
        Compare-Object $expectedFunctions ($builtManifest.FunctionsToExport | Sort-Object -Unique) |
            Should -BeNullOrEmpty
    }
}
