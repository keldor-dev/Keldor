Describe "Open-KeldorUrl" {
    BeforeAll {
        $ModuleRoot = Split-Path -Parent $PSScriptRoot
        $ManifestPath = Join-Path $ModuleRoot 'Keldor.psd1'

        Import-Module $ManifestPath -Force
    }

    It "opens the URI with the default browser when Browser is not specified" {
        InModuleScope Keldor {
            Mock Start-Process {}

            Open-KeldorUrl -Uri 'https://example.test'

            Assert-MockCalled Start-Process -Times 1 -Exactly -ParameterFilter {
                $FilePath -eq 'https://example.test'
            }
        }
    }

    It "opens a resolved named browser on Windows" {
        InModuleScope Keldor {
            Mock Get-KeldorPlatform { 'Windows' }
            Mock Get-Command { [pscustomobject]@{ Source = 'C:\Program Files\Google\Chrome\Application\chrome.exe' } } -ParameterFilter {
                $Name -eq 'chrome.exe'
            }
            Mock Start-Process {}

            Open-KeldorUrl -Uri 'https://example.test' -Browser Chrome

            Assert-MockCalled Start-Process -Times 1 -Exactly -ParameterFilter {
                $FilePath -eq 'C:\Program Files\Google\Chrome\Application\chrome.exe' -and
                $ArgumentList -eq 'https://example.test'
            }
        }
    }

    It "uses open -a for named browsers on macOS" {
        InModuleScope Keldor {
            Mock Get-KeldorPlatform { 'macOS' }
            Mock Start-Process {}

            Open-KeldorUrl -Uri 'https://example.test' -Browser Safari

            Assert-MockCalled Start-Process -Times 1 -Exactly -ParameterFilter {
                $FilePath -eq 'open' -and
                $ArgumentList[0] -eq '-a' -and
                $ArgumentList[1] -eq 'Safari' -and
                $ArgumentList[2] -eq 'https://example.test'
            }
        }
    }

    It "fails clearly when a named browser is unavailable on Linux" {
        InModuleScope Keldor {
            Mock Get-KeldorPlatform { 'Linux' }
            Mock Get-Command {}

            { Open-KeldorUrl -Uri 'https://example.test' -Browser Chrome } |
                Should -Throw "*Browser 'Chrome' was not found on Linux."
        }
    }
}
