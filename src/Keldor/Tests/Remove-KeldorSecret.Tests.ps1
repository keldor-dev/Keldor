Describe "Remove-KeldorSecret" {
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
        (Get-Command -Name Remove-KeldorSecret -Module Keldor).Name | Should -Be 'Remove-KeldorSecret'

        $alias = Get-Alias -Name Remove-KDSecret
        $alias.Definition | Should -Be 'Remove-KeldorSecret'
    }

    It "documents the alias in comment-based help" {
        $help = Get-Help Remove-KeldorSecret -Full

        $help.alertSet.alert.Text | Should -Match 'Alias: Remove-KDSecret'
        (Get-Command Remove-KeldorSecret).HelpUri | Should -Be 'https://docs.keldor.dev/powershell/keldor/Remove-KeldorSecret'
    }

    It "removes a process-scoped environment secret and returns no output by default" {
        [Environment]::SetEnvironmentVariable('KELDOR_SECRET_GITHUB_TOKEN', 'existing-secret', [EnvironmentVariableTarget]::Process)

        InModuleScope Keldor {
            $result = Remove-KeldorSecret -Name 'GitHub Token' -Provider Environment -Force

            $result | Should -BeNullOrEmpty
            [Environment]::GetEnvironmentVariable('KELDOR_SECRET_GITHUB_TOKEN', [EnvironmentVariableTarget]::Process) |
                Should -BeNullOrEmpty
        }
    }

    It "returns a non-sensitive result object with PassThru" {
        [Environment]::SetEnvironmentVariable('KELDOR_SECRET_GITHUB_TOKEN', 'existing-secret', [EnvironmentVariableTarget]::Process)

        InModuleScope Keldor {
            $result = Remove-KDSecret -Name 'GitHub Token' -Provider Environment -Force -PassThru

            $result.PSTypeNames[0] | Should -Be 'Keldor.SecretRemovalResult'
            $result.Name | Should -Be 'GitHub Token'
            $result.Provider | Should -Be 'Environment'
            $result.Action | Should -Be 'Removed'
            $result.Success | Should -BeTrue
            ($result | Out-String) | Should -Not -Match 'existing-secret'
        }
    }

    It "throws a not-found error for a missing environment secret" {
        [Environment]::SetEnvironmentVariable('KELDOR_SECRET_GITHUB_TOKEN', $null, [EnvironmentVariableTarget]::Process)

        InModuleScope Keldor {
            { Remove-KeldorSecret -Name 'GitHub Token' -Provider Environment -Force } |
                Should -Throw "Secret 'GitHub Token' was not found in the Environment provider."
        }
    }

    It "rejects Field for the Environment provider" {
        InModuleScope Keldor {
            { Remove-KeldorSecret -Name GitHubToken -Provider Environment -Field password -Force } |
                Should -Throw "*Environment provider does not support the Field parameter*"
        }
    }

    It "uses Auto when exactly one provider contains the secret" {
        InModuleScope Keldor {
            Mock Test-KeldorSecretInOnePassword { $false }
            Mock Test-KeldorSecretInSecretManagement { $true }
            Mock Test-KeldorSecretInEnvironment { $false }
            Mock Remove-KeldorSecretFromSecretManagement { 'Removed' }
            Mock Remove-KeldorSecretFromEnvironment { throw 'should-not-remove' }
            Mock Remove-KeldorSecretFromOnePassword { throw 'should-not-remove' }

            $result = Remove-KeldorSecret -Name GitHubToken -Vault DevOps -Force -PassThru

            $result.Provider | Should -Be 'SecretManagement'
            Assert-MockCalled Remove-KeldorSecretFromSecretManagement -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'GitHubToken' -and $Vault -eq 'DevOps'
            }
            Assert-MockCalled Remove-KeldorSecretFromEnvironment -Times 0
            Assert-MockCalled Remove-KeldorSecretFromOnePassword -Times 0
        }
    }

    It "fails Auto provider selection when the secret exists in more than one provider" {
        InModuleScope Keldor {
            Mock Test-KeldorSecretInOnePassword { $true }
            Mock Test-KeldorSecretInSecretManagement { $true }
            Mock Test-KeldorSecretInEnvironment { $false }
            Mock Remove-KeldorSecretFromSecretManagement { throw 'should-not-remove' }
            Mock Remove-KeldorSecretFromOnePassword { throw 'should-not-remove' }

            { Remove-KeldorSecret -Name SHRepo -Force } |
                Should -Throw "Secret 'SHRepo' exists in more than one provider. Specify -Provider explicitly."

            Assert-MockCalled Remove-KeldorSecretFromSecretManagement -Times 0
            Assert-MockCalled Remove-KeldorSecretFromOnePassword -Times 0
        }
    }

    It "fails Auto provider selection when the secret is not found" {
        InModuleScope Keldor {
            Mock Test-KeldorSecretInOnePassword { $false }
            Mock Test-KeldorSecretInSecretManagement { $false }
            Mock Test-KeldorSecretInEnvironment { $false }
            Mock Remove-KeldorSecretFromEnvironment { throw 'should-not-remove' }

            { Remove-KeldorSecret -Name MissingSecret -Force } |
                Should -Throw "Secret 'MissingSecret' was not found in any configured provider."

            Assert-MockCalled Remove-KeldorSecretFromEnvironment -Times 0
        }
    }

    It "uses only the explicitly selected provider" {
        InModuleScope Keldor {
            Mock Test-KeldorSecretInOnePassword { throw 'should-not-probe' }
            Mock Test-KeldorSecretInSecretManagement { throw 'should-not-probe' }
            Mock Test-KeldorSecretInEnvironment { throw 'should-not-probe' }
            Mock Remove-KeldorSecretFromEnvironment { 'Removed' }

            Remove-KeldorSecret -Name GitHubToken -Provider Environment -Force

            Assert-MockCalled Remove-KeldorSecretFromEnvironment -Times 1 -Exactly
            Assert-MockCalled Test-KeldorSecretInOnePassword -Times 0
            Assert-MockCalled Test-KeldorSecretInSecretManagement -Times 0
            Assert-MockCalled Test-KeldorSecretInEnvironment -Times 0
        }
    }

    It "does not call providers when WhatIf is used" {
        InModuleScope Keldor {
            Mock Remove-KeldorSecretFromEnvironment { throw 'should-not-run' }

            Remove-KeldorSecret -Name GitHubToken -Provider Environment -WhatIf

            Assert-MockCalled Remove-KeldorSecretFromEnvironment -Times 0
        }
    }

    It "removes a SecretManagement secret with a vault" {
        InModuleScope Keldor {
            Mock Get-Module { [pscustomobject]@{ Name = 'Microsoft.PowerShell.SecretManagement' } } -ParameterFilter {
                $ListAvailable -and $Name -eq 'Microsoft.PowerShell.SecretManagement'
            }
            Mock Get-Command { [pscustomobject]@{ Name = $Name } } -ParameterFilter {
                $Name -in @('Remove-Secret', 'Get-SecretInfo')
            }
            Mock Get-SecretInfo { [pscustomobject]@{ Name = 'GitHubToken' } }
            Mock Remove-Secret {}

            Remove-KeldorSecret -Name GitHubToken -Vault DevOps -Provider SecretManagement -Force

            Assert-MockCalled Remove-Secret -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'GitHubToken' -and $Vault -eq 'DevOps'
            }
        }
    }

    It "rejects Field for the SecretManagement provider" {
        InModuleScope Keldor {
            { Remove-KeldorSecret -Name GitHubToken -Provider SecretManagement -Field password -Force } |
                Should -Throw "*SecretManagement provider does not support the Field parameter*"
        }
    }

    It "does not leak provider error details from SecretManagement removal failures" {
        InModuleScope Keldor {
            Mock Get-Module { [pscustomobject]@{ Name = 'Microsoft.PowerShell.SecretManagement' } } -ParameterFilter {
                $ListAvailable -and $Name -eq 'Microsoft.PowerShell.SecretManagement'
            }
            Mock Get-Command { [pscustomobject]@{ Name = $Name } } -ParameterFilter {
                $Name -in @('Remove-Secret', 'Get-SecretInfo')
            }
            Mock Get-SecretInfo { [pscustomobject]@{ Name = 'PrivateToken' } }
            Mock Remove-Secret { throw 'provider-secret-detail' }

            { Remove-KeldorSecret -Name PrivateToken -Vault DevOps -Provider SecretManagement -Force } |
                Should -Throw "Unable to remove secret 'PrivateToken' using the SecretManagement provider."
        }
    }

    It "fails clearly for unsupported OnePassword field removal" {
        InModuleScope Keldor {
            Mock Get-Command { [pscustomobject]@{ Name = 'op' } } -ParameterFilter {
                $Name -eq 'op'
            }

            { Remove-KeldorSecret -Name GitHubToken -Provider OnePassword -Field password -Force } |
                Should -Throw "*Removing individual OnePassword fields is not supported*"
        }
    }

    It "passes discrete arguments to OnePassword item delete" {
        InModuleScope Keldor {
            Mock Get-Command { [pscustomobject]@{ Name = 'op' } } -ParameterFilter {
                $Name -eq 'op'
            }
            Mock Test-KeldorSecretInOnePassword { $true }
            Mock op {}

            Remove-KeldorSecret -Name GitHubToken -Provider OnePassword -Vault DevOps -Force

            Assert-MockCalled op -Times 1 -Exactly -ParameterFilter {
                $args[0] -eq 'item' -and
                $args[1] -eq 'delete' -and
                $args[2] -eq 'GitHubToken' -and
                $args[3] -eq '--vault' -and
                $args[4] -eq 'DevOps'
            }
        }
    }

    It "returns a field-level result object when a provider reports field removal" {
        InModuleScope Keldor {
            Mock Remove-KeldorSecretFromOnePassword { 'FieldRemoved' }

            $result = Remove-KeldorSecret -Name SHRepo -Provider OnePassword -Field password -Force -PassThru

            $result.PSTypeNames[0] | Should -Be 'Keldor.SecretRemovalResult'
            $result.Field | Should -Be 'password'
            $result.Action | Should -Be 'FieldRemoved'
        }
    }
}
