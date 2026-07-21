Describe 'Keldor PowerShell runtime compatibility' {
    BeforeAll {
        $script:ModuleRoot = Split-Path -Parent $PSScriptRoot
        $script:ManifestPath = Join-Path $script:ModuleRoot 'Keldor.psd1'

        Import-Module $script:ManifestPath -Force
    }

    It 'accepts fully supported runtime combinations' -TestCases @(
        @{ Edition = 'Desktop'; Version = '5.1' }
        @{ Edition = 'Desktop'; Version = '5.1.22621.2506' }
        @{ Edition = 'Core'; Version = '7.4.0' }
        @{ Edition = 'Core'; Version = '7.4.14' }
        @{ Edition = 'Core'; Version = '7.5.5' }
        @{ Edition = 'Core'; Version = '7.6.0' }
    ) {
        param($Edition, $Version)

        InModuleScope Keldor -Parameters @{ Edition = $Edition; Version = $Version } {
            $warning = @()
            Test-KeldorPowerShellRuntime -Edition $Edition -Version $Version -WarningVariable warning |
                Should -BeTrue
            $warning | Should -BeNullOrEmpty
        }
    }

    It 'accepts PowerShell 7.2 and 7.3 with a best-effort warning' -TestCases @(
        @{ Version = '7.2.0' }
        @{ Version = '7.2.24' }
        @{ Version = '7.3.0' }
        @{ Version = '7.3.9' }
    ) {
        param($Version)

        InModuleScope Keldor -Parameters @{ Version = $Version } {
            $warning = @()
            Test-KeldorPowerShellRuntime -Edition Core -Version $Version -WarningVariable warning |
                Should -BeTrue

            $warning.Count | Should -Be 1
            $warning[0].Message | Should -Match "PowerShell $([regex]::Escape($Version))"
            $warning[0].Message | Should -Match 'best-effort basis'
            $warning[0].Message | Should -Match 'enterprise and government environments'
            $warning[0].Message | Should -Match 'PowerShell 7.6 LTS'
            $warning[0].Message | Should -Match 'https://docs.keldor.dev/powershell/keldor/compatibility'
        }
    }

    It 'rejects unsupported runtime combinations' -TestCases @(
        @{ Edition = 'Desktop'; Version = '2.0' }
        @{ Edition = 'Desktop'; Version = '3.0' }
        @{ Edition = 'Desktop'; Version = '4.0' }
        @{ Edition = 'Desktop'; Version = '5.0' }
        @{ Edition = 'Core'; Version = '6.2' }
        @{ Edition = 'Core'; Version = '7.0' }
        @{ Edition = 'Core'; Version = '7.1' }
        @{ Edition = 'Unknown'; Version = '7.6' }
        @{ Edition = 'Desktop'; Version = 'not-a-version' }
        @{ Edition = ''; Version = $null }
    ) {
        param($Edition, $Version)

        InModuleScope Keldor -Parameters @{ Edition = $Edition; Version = $Version } {
            {
                Test-KeldorPowerShellRuntime -Edition $Edition -Version $Version
            } | Should -Throw -ErrorId 'Keldor.UnsupportedPowerShellRuntime,Test-KeldorPowerShellRuntime'
        }
    }

    It 'reports the detected runtime, support tiers, recommendation, and compatibility URL for rejected runtimes' {
        InModuleScope Keldor {
            $errorRecord = $null
            try {
                Test-KeldorPowerShellRuntime -Edition Core -Version 7.1
            } catch {
                $errorRecord = $_
            }

            $errorRecord.FullyQualifiedErrorId | Should -BeLike 'Keldor.UnsupportedPowerShellRuntime,*'
            $errorRecord.Exception.Message | Should -Match "edition 'Core' version '7.1'"
            $errorRecord.Exception.Message | Should -Match 'Windows PowerShell 5.1'
            $errorRecord.Exception.Message | Should -Match 'PowerShell 7.2 or later'
            $errorRecord.Exception.Message | Should -Match 'best-effort compatibility'
            $errorRecord.Exception.Message | Should -Match 'PowerShell 7.6 LTS'
            $errorRecord.Exception.Message | Should -Match 'https://docs.keldor.dev/powershell/keldor/compatibility'
        }
    }

    It 'declares the numeric minimum and both supported editions in the manifest' {
        $manifest = Import-PowerShellDataFile -Path $script:ManifestPath

        $manifest.PowerShellVersion | Should -Be '5.1'
        $manifest.CompatiblePSEditions | Should -Contain 'Desktop'
        $manifest.CompatiblePSEditions | Should -Contain 'Core'
        $manifest.ScriptsToProcess | Should -BeNullOrEmpty
    }
}
