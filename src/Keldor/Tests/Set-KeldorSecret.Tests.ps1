Describe "Set-KeldorSecret" {
    BeforeAll {
        $ModuleRoot = Split-Path -Parent $PSScriptRoot
        $ManifestPath = Join-Path $ModuleRoot 'Keldor.psd1'

        Import-Module $ManifestPath -Force

        $script:OriginalGitHubToken = [Environment]::GetEnvironmentVariable('KELDOR_SECRET_GITHUB_TOKEN', [EnvironmentVariableTarget]::Process)
        $script:OriginalPrivateToken = [Environment]::GetEnvironmentVariable('KELDOR_SECRET_PRIVATE_TOKEN', [EnvironmentVariableTarget]::Process)
    }

    AfterEach {
        [Environment]::SetEnvironmentVariable('KELDOR_SECRET_GITHUB_TOKEN', $script:OriginalGitHubToken, [EnvironmentVariableTarget]::Process)
        [Environment]::SetEnvironmentVariable('KELDOR_SECRET_PRIVATE_TOKEN', $script:OriginalPrivateToken, [EnvironmentVariableTarget]::Process)
    }

    It "exports the primary command and alias" {
        (Get-Command -Name Set-KeldorSecret -Module Keldor).Name | Should -Be 'Set-KeldorSecret'

        $alias = Get-Alias -Name Set-KDSecret
        $alias.Definition | Should -Be 'Set-KeldorSecret'
    }

    It "documents the alias in comment-based help" {
        $help = Get-Help Set-KeldorSecret -Full

        $help.alertSet.alert.Text | Should -Match 'Alias: Set-KDSecret'
        (Get-Command Set-KeldorSecret).HelpUri | Should -Be 'https://docs.keldor.dev/powershell/keldor/Set-KeldorSecret'
    }

    It "sets a process-scoped environment secret and returns no output by default" {
        [Environment]::SetEnvironmentVariable('KELDOR_SECRET_GITHUB_TOKEN', $null, [EnvironmentVariableTarget]::Process)

        InModuleScope Keldor {
            $result = Set-KeldorSecret -Name 'GitHub Token' -Secret 'new-secret' -Provider Environment

            $result | Should -BeNullOrEmpty
            [Environment]::GetEnvironmentVariable('KELDOR_SECRET_GITHUB_TOKEN', [EnvironmentVariableTarget]::Process) |
                Should -Be 'new-secret'
        }
    }

    It "returns a non-sensitive result object with PassThru" {
        [Environment]::SetEnvironmentVariable('KELDOR_SECRET_GITHUB_TOKEN', $null, [EnvironmentVariableTarget]::Process)

        InModuleScope Keldor {
            $result = Set-KDSecret -Name 'GitHub Token' -Secret 'new-secret' -Provider Environment -PassThru

            $result.PSTypeNames[0] | Should -Be 'Keldor.SecretWriteResult'
            $result.Name | Should -Be 'GitHub Token'
            $result.Provider | Should -Be 'Environment'
            $result.Action | Should -Be 'Created'
            $result.Success | Should -BeTrue
            ($result | Out-String) | Should -Not -Match 'new-secret'
        }
    }

    It "does not overwrite an existing environment secret without Force" {
        [Environment]::SetEnvironmentVariable('KELDOR_SECRET_GITHUB_TOKEN', 'existing-secret', [EnvironmentVariableTarget]::Process)

        InModuleScope Keldor {
            { Set-KeldorSecret -Name 'GitHub Token' -Secret 'new-secret' -Provider Environment } |
                Should -Throw "*already exists*Use -Force*"

            [Environment]::GetEnvironmentVariable('KELDOR_SECRET_GITHUB_TOKEN', [EnvironmentVariableTarget]::Process) |
                Should -Be 'existing-secret'
        }
    }

    It "overwrites an existing environment secret with Force" {
        [Environment]::SetEnvironmentVariable('KELDOR_SECRET_GITHUB_TOKEN', 'existing-secret', [EnvironmentVariableTarget]::Process)

        InModuleScope Keldor {
            $result = Set-KeldorSecret -Name 'GitHub Token' -Secret 'new-secret' -Provider Environment -Force -PassThru

            $result.Action | Should -Be 'Updated'
            [Environment]::GetEnvironmentVariable('KELDOR_SECRET_GITHUB_TOKEN', [EnvironmentVariableTarget]::Process) |
                Should -Be 'new-secret'
        }
    }

    It "converts SecureString only at the environment write boundary" {
        [Environment]::SetEnvironmentVariable('KELDOR_SECRET_PRIVATE_TOKEN', $null, [EnvironmentVariableTarget]::Process)

        InModuleScope Keldor {
            $secureSecret = ConvertTo-SecureString -String 'secure-secret' -AsPlainText -Force

            Set-KeldorSecret -Name 'Private Token' -Secret $secureSecret -Provider Environment

            [Environment]::GetEnvironmentVariable('KELDOR_SECRET_PRIVATE_TOKEN', [EnvironmentVariableTarget]::Process) |
                Should -Be 'secure-secret'
        }
    }

    It "rejects Field for the Environment provider" {
        InModuleScope Keldor {
            { Set-KeldorSecret -Name GitHubToken -Secret 'new-secret' -Provider Environment -Field password } |
                Should -Throw "*Environment provider does not support the Field parameter*"
        }
    }

    It "uses SecretManagement when Auto can safely write through it" {
        InModuleScope Keldor {
            Mock Get-Module { [pscustomobject]@{ Name = 'Microsoft.PowerShell.SecretManagement' } } -ParameterFilter {
                $ListAvailable -and $Name -eq 'Microsoft.PowerShell.SecretManagement'
            }
            Mock Get-Command { [pscustomobject]@{ Name = $Name } } -ParameterFilter {
                $Name -in @('Set-Secret', 'Get-SecretInfo')
            }
            Mock Get-SecretInfo { $null }
            Mock Set-Secret {}
            Mock Set-KeldorSecretToEnvironment { throw 'should-not-fallback' }

            $result = Set-KeldorSecret -Name GitHubToken -Secret 'new-secret' -Vault DevOps -PassThru

            $result.Provider | Should -Be 'SecretManagement'
            Assert-MockCalled Set-Secret -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'GitHubToken' -and
                $Secret -eq 'new-secret' -and
                $Vault -eq 'DevOps'
            }
            Assert-MockCalled Set-KeldorSecretToEnvironment -Times 0
        }
    }

    It "uses Environment when Auto cannot use SecretManagement" {
        [Environment]::SetEnvironmentVariable('KELDOR_SECRET_GITHUB_TOKEN', $null, [EnvironmentVariableTarget]::Process)

        InModuleScope Keldor {
            Mock Get-Module { $null } -ParameterFilter {
                $ListAvailable -and $Name -eq 'Microsoft.PowerShell.SecretManagement'
            }
            Mock Get-Command { $null } -ParameterFilter {
                $Name -eq 'Set-Secret'
            }

            $result = Set-KeldorSecret -Name 'GitHub Token' -Secret 'new-secret' -PassThru

            $result.Provider | Should -Be 'Environment'
            [Environment]::GetEnvironmentVariable('KELDOR_SECRET_GITHUB_TOKEN', [EnvironmentVariableTarget]::Process) |
                Should -Be 'new-secret'
        }
    }

    It "does not fall back after a selected provider write failure" {
        InModuleScope Keldor {
            Mock Get-Module { [pscustomobject]@{ Name = 'Microsoft.PowerShell.SecretManagement' } } -ParameterFilter {
                $ListAvailable -and $Name -eq 'Microsoft.PowerShell.SecretManagement'
            }
            Mock Get-Command { [pscustomobject]@{ Name = $Name } } -ParameterFilter {
                $Name -in @('Set-Secret', 'Get-SecretInfo')
            }
            Mock Get-SecretInfo { $null }
            Mock Set-Secret { throw 'provider-secret-detail' }
            Mock Set-KeldorSecretToEnvironment { throw 'should-not-fallback' }

            { Set-KeldorSecret -Name PrivateToken -Secret 'new-secret' } |
                Should -Throw "Unable to set secret 'PrivateToken' using the SecretManagement provider."

            Assert-MockCalled Set-KeldorSecretToEnvironment -Times 0
        }
    }

    It "does not call providers when WhatIf is used" {
        InModuleScope Keldor {
            Mock Set-KeldorSecretToEnvironment { throw 'should-not-run' }

            Set-KeldorSecret -Name GitHubToken -Secret 'new-secret' -Provider Environment -WhatIf

            Assert-MockCalled Set-KeldorSecretToEnvironment -Times 0
        }
    }

    It "passes SecureString through to SecretManagement without plaintext conversion" {
        InModuleScope Keldor {
            $secureSecret = ConvertTo-SecureString -String 'secure-secret' -AsPlainText -Force

            Mock Get-Module { [pscustomobject]@{ Name = 'Microsoft.PowerShell.SecretManagement' } } -ParameterFilter {
                $ListAvailable -and $Name -eq 'Microsoft.PowerShell.SecretManagement'
            }
            Mock Get-Command { [pscustomobject]@{ Name = $Name } } -ParameterFilter {
                $Name -in @('Set-Secret', 'Get-SecretInfo')
            }
            Mock Get-SecretInfo { $null }
            Mock Set-Secret {}

            Set-KeldorSecret -Name GitHubToken -Secret $secureSecret -Provider SecretManagement

            Assert-MockCalled Set-Secret -Times 1 -Exactly -ParameterFilter {
                $Secret -is [System.Security.SecureString]
            }
        }
    }

    It "requires Force before replacing an existing SecretManagement secret" {
        InModuleScope Keldor {
            Mock Get-Module { [pscustomobject]@{ Name = 'Microsoft.PowerShell.SecretManagement' } } -ParameterFilter {
                $ListAvailable -and $Name -eq 'Microsoft.PowerShell.SecretManagement'
            }
            Mock Get-Command { [pscustomobject]@{ Name = $Name } } -ParameterFilter {
                $Name -in @('Set-Secret', 'Get-SecretInfo')
            }
            Mock Get-SecretInfo { [pscustomobject]@{ Name = 'GitHubToken' } }
            Mock Set-Secret {}

            { Set-KeldorSecret -Name GitHubToken -Secret 'new-secret' -Provider SecretManagement } |
                Should -Throw "*already exists*Use -Force*"

            Assert-MockCalled Set-Secret -Times 0
        }
    }

    It "writes an existing SecretManagement secret when Force is supplied" {
        InModuleScope Keldor {
            Mock Get-Module { [pscustomobject]@{ Name = 'Microsoft.PowerShell.SecretManagement' } } -ParameterFilter {
                $ListAvailable -and $Name -eq 'Microsoft.PowerShell.SecretManagement'
            }
            Mock Get-Command { [pscustomobject]@{ Name = $Name } } -ParameterFilter {
                $Name -in @('Set-Secret', 'Get-SecretInfo')
            }
            Mock Get-SecretInfo { [pscustomobject]@{ Name = 'GitHubToken' } }
            Mock Set-Secret {}

            $result = Set-KeldorSecret -Name GitHubToken -Secret 'new-secret' -Provider SecretManagement -Force -PassThru

            $result.Action | Should -Be 'Updated'
            Assert-MockCalled Set-Secret -Times 1 -Exactly
        }
    }

    It "fails clearly for OnePassword writes instead of using command-line secret arguments" {
        InModuleScope Keldor {
            Mock Get-Command { [pscustomobject]@{ Name = 'op' } } -ParameterFilter {
                $Name -eq 'op'
            }

            { Set-KeldorSecret -Name GitHubToken -Secret 'new-secret' -Provider OnePassword } |
                Should -Throw "*OnePassword provider is not supported*"
        }
    }

    It "rejects unsupported secret input types" {
        InModuleScope Keldor {
            { Set-KeldorSecret -Name GitHubToken -Secret 123 -Provider Environment } |
                Should -Throw "Secret must be a string or SecureString."
        }
    }
}
