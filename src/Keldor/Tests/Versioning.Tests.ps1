Describe "Keldor versioning" {
    BeforeAll {
        $script:ModuleRoot = Split-Path -Parent $PSScriptRoot
        $script:RepoRoot = Split-Path -Parent (Split-Path -Parent $script:ModuleRoot)
        $script:ManifestPath = Join-Path $script:ModuleRoot 'Keldor.psd1'
        $script:BuildScript = Join-Path $script:RepoRoot 'build.ps1'

        . $script:BuildScript
    }

    It "uses 0.1.0 as the authoritative source manifest version" {
        $manifest = Test-ModuleManifest -Path $script:ManifestPath

        $manifest.Version.ToString() | Should -Be '0.1.0'
    }

    It "validates semantic versions and prerelease versions" {
        Test-KeldorSemanticVersion -Version '0.1.0' | Should -BeTrue
        Test-KeldorSemanticVersion -Version '1.1.0-preview.1' | Should -BeTrue
        Test-KeldorSemanticVersion -Version '1.1.0-rc.1' | Should -BeTrue
        Test-KeldorSemanticVersion -Version '1.1' | Should -BeFalse
        Test-KeldorSemanticVersion -Version '1.1.0.0' | Should -BeFalse
    }

    It "normal builds leave the source manifest unchanged" {
        $before = Get-Content -Path $script:ManifestPath -Raw

        Invoke-KeldorBuild -Task Build

        $after = Get-Content -Path $script:ManifestPath -Raw
        $after | Should -Be $before
    }

    It "injects release versions into the packaged manifest only" {
        Invoke-KeldorBuild -Task Release -Version '1.1.0-preview.1'

        $builtManifestPath = Join-Path $script:RepoRoot 'out/Keldor/Keldor.psd1'
        $builtManifest = Import-PowerShellDataFile -Path $builtManifestPath
        $sourceManifest = Test-ModuleManifest -Path $script:ManifestPath

        $builtManifest.ModuleVersion | Should -Be '1.1.0'
        $builtManifest.PrivateData.PSData.Prerelease | Should -Be 'preview.1'
        $sourceManifest.Version.ToString() | Should -Be '0.1.0'
    }

    It 'writes explicit function exports into packaged manifests' {
        Invoke-KeldorBuild -Task Build

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
