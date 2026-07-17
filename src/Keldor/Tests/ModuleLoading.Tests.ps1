Describe 'Keldor module loading' {
    BeforeAll {
        $script:ModuleRoot = Split-Path -Parent $PSScriptRoot
        $script:ManifestPath = Join-Path $script:ModuleRoot 'Keldor.psd1'
    }

    BeforeEach {
        Remove-Module Keldor -Force -ErrorAction SilentlyContinue
    }

    It 'imports without success-stream output and supports removal and re-import' {
        $output = @(& { Import-Module $script:ManifestPath -Force -PassThru:$false } *>&1)

        $output | Should -BeNullOrEmpty
        Get-Module Keldor | Should -Not -BeNullOrEmpty

        Remove-Module Keldor -Force
        { Import-Module $script:ManifestPath -Force -ErrorAction Stop } | Should -Not -Throw
    }

    It 'imports from a module path containing spaces' {
        $spacedRoot = Join-Path $TestDrive 'Keldor module with spaces'
        Copy-Item $script:ModuleRoot -Destination $spacedRoot -Recurse
        $spacedManifest = Join-Path $spacedRoot 'Keldor.psd1'

        { Import-Module $spacedManifest -Force -ErrorAction Stop } | Should -Not -Throw
        (Get-Module Keldor).Path | Should -Be (Join-Path $spacedRoot 'Keldor.psm1')
    }

    It 'does not depend on the current directory' {
        $originalLocation = Get-Location
        $temporaryLocation = Join-Path ([IO.Path]::GetTempPath()) 'Keldor Module Loading Test'
        New-Item -Path $temporaryLocation -ItemType Directory -Force | Out-Null

        try {
            Set-Location $temporaryLocation
            { Import-Module $script:ManifestPath -Force -ErrorAction Stop } | Should -Not -Throw
        } finally {
            Set-Location $originalLocation
            Remove-Item $temporaryLocation -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'loads Common and only the current platform public folder' {
        Import-Module $script:ManifestPath -Force
        $platform = Get-KeldorPlatform
        $actualNames = @(Get-Command -Module Keldor -CommandType Function | Select-Object -ExpandProperty Name)
        $expectedNames = @(
            Get-ChildItem (Join-Path $script:ModuleRoot 'Public/Common') -Filter '*.ps1' -File |
                Select-Object -ExpandProperty BaseName
        )
        $platformPath = Join-Path $script:ModuleRoot "Public/$platform"
        if (Test-Path $platformPath) {
            $expectedNames += Get-ChildItem $platformPath -Filter '*.ps1' -File |
                Select-Object -ExpandProperty BaseName
        }

        Compare-Object ($expectedNames | Sort-Object -Unique) ($actualNames | Sort-Object -Unique) | Should -BeNullOrEmpty
        @($actualNames).Count | Should -Be @($actualNames | Sort-Object -Unique).Count
        $actualAliases = @(Get-Command -Module Keldor -CommandType Alias | Select-Object -ExpandProperty Name)
        @($actualAliases).Count | Should -Be @($actualAliases | Sort-Object -Unique).Count
    }

    It 'loads the runtime guard before configuration and all discovered commands' {
        $loader = Get-Content (Join-Path $script:ModuleRoot 'Keldor.psm1') -Raw
        $guardCall = $loader.IndexOf('Test-KeldorPowerShellRuntime -Version')
        $configLoad = $loader.IndexOf("@('config.ps1', 'classes.ps1')")
        $discovery = $loader.IndexOf('$loadGroups = @(')

        $guardCall | Should -BeGreaterThan -1
        $guardCall | Should -BeLessThan $configLoad
        $configLoad | Should -BeLessThan $discovery
    }

    It 'keeps import offline and avoids process-wide policy changes in the root loader' {
        $loader = Get-Content (Join-Path $script:ModuleRoot 'Keldor.psm1') -Raw

        $loader | Should -Not -Match 'Invoke-WebRequest|Invoke-RestMethod|Start-BitsTransfer'
        $loader | Should -Not -Match 'Set-ExecutionPolicy|Enable-PSRemoting|Set-PSSessionConfiguration'
        $loader | Should -Not -Match 'Write-Host|\$global:'
        $loader | Should -Match 'Sort-Object -Property FullName'
    }

    It 'preserves the original exception on a required-file load failure' {
        Import-Module $script:ManifestPath -Force

        InModuleScope Keldor {
            $innerException = New-Object System.InvalidOperationException 'original failure'
            $file = New-Object System.IO.FileInfo (Join-Path $TestDrive 'Broken.ps1')
            $exception = New-KeldorLoadException -File $file -InnerException $innerException

            $exception.Message | Should -Match 'Broken.ps1'
            $exception.InnerException | Should -Be $innerException
        }
    }
}
