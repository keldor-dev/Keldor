Describe 'Keldor PowerShell runtime compatibility' {
    BeforeAll {
        $script:ModuleRoot = Split-Path -Parent $PSScriptRoot
        $script:ManifestPath = Join-Path $script:ModuleRoot 'Keldor.psd1'

        Import-Module $script:ManifestPath -Force
    }

    It 'accepts supported runtime combinations' -TestCases @(
        @{ Edition = 'Desktop'; Version = '5.1' }
        @{ Edition = 'Desktop'; Version = '5.1.22621.2506' }
        @{ Edition = 'Core'; Version = '7.4.0' }
        @{ Edition = 'Core'; Version = '7.4.14' }
        @{ Edition = 'Core'; Version = '7.5.5' }
        @{ Edition = 'Core'; Version = '7.6.0' }
    ) {
        param($Edition, $Version)

        InModuleScope Keldor -Parameters @{ Edition = $Edition; Version = $Version } {
            Test-KeldorPowerShellRuntime -Edition $Edition -Version $Version | Should -BeTrue
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
        @{ Edition = 'Core'; Version = '7.2' }
        @{ Edition = 'Core'; Version = '7.3' }
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

    It 'reports the detected runtime, both minimums, retirement policy, and compatibility URL' {
        InModuleScope Keldor {
            $errorRecord = $null
            try {
                Test-KeldorPowerShellRuntime -Edition Core -Version 7.3
            } catch {
                $errorRecord = $_
            }

            $errorRecord.FullyQualifiedErrorId | Should -BeLike 'Keldor.UnsupportedPowerShellRuntime,*'
            $errorRecord.Exception.Message | Should -Match "edition 'Core' version '7.3'"
            $errorRecord.Exception.Message | Should -Match 'Windows PowerShell 5.1'
            $errorRecord.Exception.Message | Should -Match 'PowerShell 7.4'
            $errorRecord.Exception.Message | Should -Match 'Obsolete PowerShell releases are intentionally unsupported'
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
