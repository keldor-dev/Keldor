Describe 'Get-KeldorPlatform' {
    BeforeAll {
        $script:ModuleRoot = Split-Path -Parent $PSScriptRoot
        $script:ManifestPath = Join-Path $script:ModuleRoot 'Keldor.psd1'
        $script:FunctionPath = Join-Path $script:ModuleRoot 'Public/Common/Get-KeldorPlatform.ps1'

        Import-Module $script:ManifestPath -Force
    }

    It 'is exported as a function without an alias' {
        $command = Get-Command -Name Get-KeldorPlatform -Module Keldor
        $aliases = Get-Alias -ErrorAction SilentlyContinue | Where-Object { $_.Definition -eq 'Get-KeldorPlatform' }

        $command.CommandType | Should -Be 'Function'
        $aliases | Should -BeNullOrEmpty
    }

    It 'declares string output' {
        $command = Get-Command -Name Get-KeldorPlatform -Module Keldor

        $command.OutputType.Type.Name | Should -Contain 'String'
    }

    It 'returns only a contract value' {
        Get-KeldorPlatform | Should -BeIn @('Windows', 'macOS', 'Linux', 'Unknown')
    }

    It 'detects the current platform' {
        $expected = if ($IsWindows) {
            'Windows'
        } elseif ($IsMacOS) {
            'macOS'
        } elseif ($IsLinux) {
            'Linux'
        } elseif ($PSVersionTable.PSEdition -eq 'Desktop') {
            'Windows'
        } else {
            'Unknown'
        }

        Get-KeldorPlatform | Should -Be $expected
    }

    It 'recognizes supported RuntimeInformation descriptions' -TestCases @(
        @{ Description = 'Microsoft Windows 10.0.19045'; Expected = 'Windows' }
        @{ Description = 'Linux 6.8.0'; Expected = 'Linux' }
        @{ Description = 'Darwin 25.0.0'; Expected = 'macOS' }
        @{ Description = 'macOS 15.0'; Expected = 'macOS' }
        @{ Description = 'Mac OS X 10.15'; Expected = 'macOS' }
    ) {
        param($Description, $Expected)

        InModuleScope Keldor -Parameters @{ Description = $Description; Expected = $Expected } {
            Get-KeldorRuntimeInformationPlatform -OSDescription $Description | Should -Be $Expected
        }
    }

    It 'uses RuntimeInformation after automatic platform variables' -Skip:($PSVersionTable.PSEdition -eq 'Desktop') {
        InModuleScope Keldor {
            Mock Get-Variable { $null } -ParameterFilter { $Name -in @('IsWindows', 'IsMacOS', 'IsLinux') }
            Mock Get-KeldorRuntimeInformationPlatform { 'Linux' }
            Mock Get-KeldorLegacyWindowsPlatform { throw 'Legacy detection should not run.' }

            Get-KeldorPlatform | Should -Be 'Linux'
        }
    }

    It 'uses the legacy Windows fallback when RuntimeInformation is unavailable' -Skip:($PSVersionTable.PSEdition -eq 'Desktop') {
        InModuleScope Keldor {
            Mock Get-Variable { $null } -ParameterFilter { $Name -in @('IsWindows', 'IsMacOS', 'IsLinux') }
            Mock Get-KeldorRuntimeInformationPlatform { $null }
            Mock Get-KeldorLegacyWindowsPlatform { 'Windows' }

            Get-KeldorPlatform | Should -Be 'Windows'
        }
    }

    It 'returns Unknown when runtime and legacy detection fail' -Skip:($PSVersionTable.PSEdition -eq 'Desktop') {
        InModuleScope Keldor {
            Mock Get-Variable { $null } -ParameterFilter { $Name -in @('IsWindows', 'IsMacOS', 'IsLinux') }
            Mock Get-KeldorRuntimeInformationPlatform { throw 'RuntimeInformation unavailable.' }
            Mock Get-KeldorLegacyWindowsPlatform { $null }

            { Get-KeldorPlatform } | Should -Not -Throw
            Get-KeldorPlatform | Should -Be 'Unknown'
        }
    }

    It 'provides complete public help' {
        $help = Get-Help Get-KeldorPlatform -Full
        $functionText = Get-Content -Path $script:FunctionPath -Raw

        $help.Synopsis | Should -Not -BeNullOrEmpty
        $help.Description.Text | Should -Match 'operating-system family'
        @($help.Examples.Example).Count | Should -BeGreaterOrEqual 2
        $help.ReturnValues.ReturnValue.Type.Name | Should -Contain 'System.String'
        $functionText | Should -Match '(?m)^\s*\.LINK\s*\r?\n\s*https://docs\.keldor\.dev/powershell/keldor/Get-KeldorPlatform'
        $functionText | Should -Match 'edition'
        $functionText | Should -Match 'distribution'
        $functionText | Should -Match 'architecture'
        $functionText | Should -Match 'build'
        $functionText | Should -Match 'version'
    }
}
