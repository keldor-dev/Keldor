Describe "Keldor Module" {
    BeforeAll {
        $ModuleRoot = Split-Path -Parent $PSScriptRoot
        $ManifestPath = Join-Path $ModuleRoot 'Keldor.psd1'

        Import-Module $ManifestPath -Force

        $script:Platform = if ((Get-Variable -Name IsWindows -ErrorAction SilentlyContinue) -and $IsWindows) {
            'Windows'
        } elseif ((Get-Variable -Name IsMacOS -ErrorAction SilentlyContinue) -and $IsMacOS) {
            'macOS'
        } elseif ((Get-Variable -Name IsLinux -ErrorAction SilentlyContinue) -and $IsLinux) {
            'Linux'
        } elseif ($PSVersionTable.PSEdition -eq 'Desktop') {
            'Windows'
        } else {
            'Unknown'
        }
    }

    It "Should import the module" {
        Get-Module Keldor | Should -Not -BeNullOrEmpty
    }

    It "Should export common functions" {
        $commandNames = (Get-Command -Module Keldor).Name

        $commandNames | Should -Contain "Format-IPList"
        $commandNames | Should -Contain "Get-DayOfYear"
    }

    It "Should export only the current platform functions" {
        $commandNames = (Get-Command -Module Keldor).Name

        if ($script:Platform -eq 'Windows') {
            $commandNames | Should -Contain "Get-WSToolsVersion"
        } else {
            $commandNames | Should -Not -Contain "Get-WSToolsVersion"
        }
    }

    It "Should expose online help URIs for exported functions" {
        $commands = Get-Command -Module Keldor -CommandType Function

        foreach ($command in $commands) {
            $command.HelpUri | Should -Be "https://docs.keldor.dev/powershell/keldor/$($command.Name)"
        }
    }

    It "Should include matching online help links in comment-based help" {
        $commands = Get-Command -Module Keldor -CommandType Function

        foreach ($command in $commands) {
            $functionFile = Get-ChildItem -Path (Join-Path $ModuleRoot 'Public') -File -Recurse |
                Where-Object { $_.BaseName -eq $command.Name } |
                Select-Object -First 1
            $functionText = Get-Content -Path $functionFile.FullName -Raw
            $expectedLink = "https://docs.keldor.dev/powershell/keldor/$($command.Name)"

            $functionText | Should -Match "(?m)^\s*\.LINK\s*`r?`n\s*$([regex]::Escape($expectedLink))"
        }
    }

    It "Should point updateable help to the docs static help endpoint" {
        $manifest = Import-PowerShellDataFile -Path $ManifestPath

        $manifest.HelpInfoURI | Should -Be 'https://docs.keldor.dev/powershell-help/keldor/'
    }
}
