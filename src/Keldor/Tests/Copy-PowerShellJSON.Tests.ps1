Describe "Copy-PowerShellJSON" {
    BeforeAll {
        $ModuleRoot = Split-Path -Parent $PSScriptRoot
        $ManifestPath = Join-Path $ModuleRoot 'Keldor.psd1'

        Import-Module $ManifestPath -Force

        $script:OriginalAppData = $env:APPDATA
        $script:OriginalHome = $env:HOME
    }

    AfterAll {
        $env:APPDATA = $script:OriginalAppData
        $env:HOME = $script:OriginalHome
    }

    It "copies snippets to the Windows VS Code snippets folder" {
        InModuleScope Keldor {
            $env:APPDATA = '/tmp/AppData/Roaming'

            Mock Get-KeldorPlatform { 'Windows' }
            Mock Test-Path { $true }
            Mock Copy-Item {}

            Copy-PowerShellJSON

            $expectedDestination = Join-Path -Path $env:APPDATA -ChildPath 'Code/User/snippets/powershell.json'
            Assert-MockCalled Copy-Item -Times 1 -Exactly -ParameterFilter {
                $Destination -eq $expectedDestination -and
                $Path -match '[\\/]Resources[\\/]powershell\.json$' -and
                $Force
            }
        }
    }

    It "copies snippets to the macOS VS Code snippets folder" {
        InModuleScope Keldor {
            $env:HOME = '/Users/testuser'

            Mock Get-KeldorPlatform { 'macOS' }
            Mock Test-Path { $true }
            Mock Copy-Item {}

            Copy-PowerShellJSON

            $expectedDestination = Join-Path -Path $HOME -ChildPath 'Library/Application Support/Code/User/snippets/powershell.json'
            Assert-MockCalled Copy-Item -Times 1 -Exactly -ParameterFilter {
                $Destination -eq $expectedDestination -and
                $Path -match '[\\/]Resources[\\/]powershell\.json$' -and
                $Force
            }
        }
    }

    It "copies snippets to the Linux VS Code snippets folder" {
        InModuleScope Keldor {
            $env:HOME = '/home/testuser'

            Mock Get-KeldorPlatform { 'Linux' }
            Mock Test-Path { $true }
            Mock Copy-Item {}

            Copy-PowerShellJSON

            $expectedDestination = Join-Path -Path $HOME -ChildPath '.config/Code/User/snippets/powershell.json'
            Assert-MockCalled Copy-Item -Times 1 -Exactly -ParameterFilter {
                $Destination -eq $expectedDestination -and
                $Path -match '[\\/]Resources[\\/]powershell\.json$' -and
                $Force
            }
        }
    }

    It "creates the snippets directory when it is missing" {
        InModuleScope Keldor {
            $env:HOME = '/home/testuser'
            $snippetPath = Join-Path -Path $HOME -ChildPath '.config/Code/User/snippets'

            Mock Get-KeldorPlatform { 'Linux' }
            Mock Test-Path {
                if ($Path -eq $snippetPath) {
                    return $false
                }

                return $true
            }
            Mock New-Item { [pscustomobject]@{} }
            Mock Copy-Item {}

            Copy-PowerShellJSON

            Assert-MockCalled New-Item -Times 1 -Exactly -ParameterFilter {
                $Path -eq $snippetPath -and
                $ItemType -eq 'Directory' -and
                $Force
            }
        }
    }

    It "throws when the snippet source file is missing" {
        InModuleScope Keldor {
            $env:HOME = '/home/testuser'

            Mock Get-KeldorPlatform { 'Linux' }
            Mock Test-Path {
                if ($Path -match '[\\/]Resources[\\/]powershell\.json$') {
                    return $false
                }

                return $true
            }
            Mock Copy-Item {}

            { Copy-PowerShellJSON } | Should -Throw '*Source file not found*'
            Assert-MockCalled Copy-Item -Times 0
        }
    }
}
