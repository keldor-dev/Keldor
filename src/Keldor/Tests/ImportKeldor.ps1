Describe "Keldor Module" {
    BeforeAll {
        $ModuleRoot = Split-Path -Parent $PSScriptRoot
        $ManifestPath = Join-Path $ModuleRoot 'Keldor.psd1'

        Import-Module $ManifestPath -Force
    }

    It "Should import the module" {
        Get-Module Keldor | Should -Not -BeNullOrEmpty
    }

    It "Should have expected functions" {
        (Get-Command -Module Keldor).Name | Should -Contain "Get-WSToolsVersion"
    }

    It "Should expose online help URIs for exported functions" {
        $commands = Get-Command -Module Keldor -CommandType Function

        foreach ($command in $commands) {
            $command.HelpUri | Should -Be "https://docs.keldor.dev/powershell/keldor/$($command.Name)"
        }
    }

    It "Should point updateable help to the docs static help endpoint" {
        $manifest = Import-PowerShellDataFile -Path $ManifestPath

        $manifest.HelpInfoURI | Should -Be 'https://docs.keldor.dev/powershell-help/keldor/'
    }
}
