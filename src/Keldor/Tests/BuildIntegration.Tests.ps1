BeforeAll {
    $RepositoryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../..'
    $BuildScript = Join-Path -Path $RepositoryRoot -ChildPath 'build.ps1'
    $BuildConfiguration = Join-Path -Path $RepositoryRoot -ChildPath 'build.config.psd1'
    $LocalBuildModulePath = $env:KELDOR_BUILD_MODULE_PATH

    if (-not $LocalBuildModulePath) {
        $AvailableBuildModule = Get-Module -ListAvailable -Name Keldor.Build.PowerShell |
            Where-Object { $_.Version -eq [version]'0.2.0' } |
            Select-Object -First 1

        if (-not $AvailableBuildModule) {
            throw 'Keldor.Build.PowerShell 0.2.0 is required for build integration tests.'
        }
    }
}

Describe 'Keldor build integration' {
    AfterEach {
        Get-Module -Name Keldor | Remove-Module -Force -ErrorAction SilentlyContinue
    }

    It 'keeps the repository entry point as a build-module consumer' {
        $BuildScriptContent = Get-Content -LiteralPath $BuildScript -Raw

        $BuildScriptContent | Should -Match 'Import-Module'
        $BuildScriptContent | Should -Match 'Invoke-KeldorPowerShellBuild'
        $BuildScriptContent | Should -Not -Match 'function\s+(Copy|Update|Test)-Keldor'
    }

    It 'uses a valid repository build configuration' {
        $ImportParameters = @{
            Force       = $true
            ErrorAction = 'Stop'
        }

        if ($LocalBuildModulePath) {
            $ImportParameters.Name = Join-Path -Path $LocalBuildModulePath -ChildPath 'Keldor.Build.PowerShell.psd1'
        } else {
            $ImportParameters.Name = 'Keldor.Build.PowerShell'
            $ImportParameters.RequiredVersion = [version]'0.2.0'
        }

        Import-Module @ImportParameters
        $Configuration = Test-KeldorPowerShellBuildConfiguration -ConfigurationPath $BuildConfiguration

        $Configuration.ModuleName | Should -Be 'Keldor'
        $Configuration.ExpectedManifestVersion | Should -Be '0.1.0'
    }

    It 'builds an importable package without tests or build dependencies' {
        $BuildParameters = @{
            Task        = 'Build'
            ErrorAction = 'Stop'
        }

        if ($LocalBuildModulePath) {
            $BuildParameters.BuildModulePath = $LocalBuildModulePath
        }

        $Result = & $BuildScript @BuildParameters
        $BuiltManifest = Join-Path -Path $Result.OutputPath -ChildPath 'Keldor.psd1'

        Test-ModuleManifest -Path $BuiltManifest | Should -Not -BeNullOrEmpty
        { Import-Module -Name $BuiltManifest -Force -ErrorAction Stop } | Should -Not -Throw
        Test-Path -LiteralPath (Join-Path $Result.OutputPath 'Tests') | Should -BeFalse
        Test-Path -LiteralPath (Join-Path $Result.OutputPath 'build.config.psd1') | Should -BeFalse
        Test-Path -LiteralPath (Join-Path $Result.OutputPath 'Keldor.Build.PowerShell.psd1') | Should -BeFalse
    }
}
