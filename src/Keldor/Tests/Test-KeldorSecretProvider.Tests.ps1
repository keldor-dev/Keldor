Describe "Test-KeldorSecretProvider" {
    BeforeAll {
        $ModuleRoot = Split-Path -Parent $PSScriptRoot
        $ManifestPath = Join-Path $ModuleRoot 'Keldor.psd1'

        Import-Module $ManifestPath -Force
    }

    It "exports the primary command and alias" {
        (Get-Command -Name Test-KeldorSecretProvider -Module Keldor).Name | Should -Be 'Test-KeldorSecretProvider'

        $alias = Get-Alias -Name Test-KDSecretProvider
        $alias.Definition | Should -Be 'Test-KeldorSecretProvider'
    }

    It "documents the alias in comment-based help" {
        $help = Get-Help Test-KeldorSecretProvider -Full

        $help.alertSet.alert.Text | Should -Match 'Alias: Test-KDSecretProvider'
        (Get-Command Test-KeldorSecretProvider).HelpUri | Should -Be 'https://docs.keldor.dev/powershell/keldor/Test-KeldorSecretProvider'
    }

    It "tests all providers when Name is omitted" {
        InModuleScope Keldor {
            Mock Get-Command { $null }
            Mock Get-Module { $null }

            $results = @(Test-KeldorSecretProvider)

            $results.Name | Should -Be @('OnePassword', 'SecretManagement', 'Environment')
            $results[0].PSTypeNames[0] | Should -Be 'Keldor.SecretProviderTestResult'
            $results[0].PSObject.Properties.Name | Should -Contain 'TestedAt'
            $results[0].PSObject.Properties.Name | Should -Contain 'Duration'
        }
    }

    It "tests one provider by case-insensitive name" {
        InModuleScope Keldor {
            $result = Test-KeldorSecretProvider -Name environment

            $result.Name | Should -Be 'Environment'
            $result.Success | Should -BeTrue
            $result.Status | Should -Be 'Passed'
        }
    }

    It "tests multiple providers" {
        InModuleScope Keldor {
            Mock Get-Command { $null }

            $results = @(Test-KeldorSecretProvider -Name OnePassword, Environment)

            $results.Name | Should -Be @('OnePassword', 'Environment')
        }
    }

    It "accepts provider names from the pipeline" {
        InModuleScope Keldor {
            Mock Get-Command { $null }

            $results = @('Environment', 'OnePassword') | Test-KeldorSecretProvider

            $results.Name | Should -Be @('OnePassword', 'Environment')
        }
    }

    It "throws for unknown providers and Auto" {
        InModuleScope Keldor {
            { Test-KeldorSecretProvider -Name UnknownProvider } |
                Should -Throw "Secret provider 'UnknownProvider' was not found."

            { Test-KeldorSecretProvider -Name Auto } |
                Should -Throw "Auto is provider selection behavior, not a secret provider."
        }
    }

    It "rejects Vault for providers that do not support vaults" {
        InModuleScope Keldor {
            { Test-KeldorSecretProvider -Name Environment -Vault DevOps } |
                Should -Throw "Parameter -Vault is not supported by provider 'Environment'."
        }
    }

    It "rejects Detailed and Quiet together" {
        InModuleScope Keldor {
            { Test-KeldorSecretProvider -Name Environment -Detailed -Quiet } |
                Should -Throw "Parameters Detailed and Quiet cannot be used together."
        }
    }

    It "returns Boolean output with Quiet" {
        InModuleScope Keldor {
            Test-KeldorSecretProvider -Name Environment -Quiet | Should -BeTrue

            Mock Get-Command { $null } -ParameterFilter {
                $Name -eq 'op'
            }

            Test-KeldorSecretProvider -Name OnePassword -Quiet | Should -BeFalse
        }
    }

    It "includes detailed child checks without sensitive values" {
        InModuleScope Keldor {
            $result = Test-KeldorSecretProvider -Name Environment -Detailed

            $result.Checks | Should -Not -BeNullOrEmpty
            $result.Checks[0].PSTypeNames[0] | Should -Be 'Keldor.SecretProviderCheckResult'
            ($result | Out-String) | Should -Not -Match 'secret-value|token|session'
        }
    }

    It "reports OnePassword executable missing as a failed object" {
        InModuleScope Keldor {
            Mock Get-Command { $null } -ParameterFilter {
                $Name -eq 'op'
            }

            $result = Test-KeldorSecretProvider -Name OnePassword -Detailed

            $result.Success | Should -BeFalse
            $result.Status | Should -Be 'NotInstalled'
            ($result.Checks | Where-Object Name -EQ 'ExecutablePresent').Success | Should -BeFalse
        }
    }

    It "reports OnePassword version failure and unauthenticated state without raw output" {
        InModuleScope Keldor {
            Mock Get-Command { [pscustomobject]@{ Name = 'op'; CommandType = 'Application' } } -ParameterFilter {
                $Name -eq 'op'
            }
            Mock op {
                if ($args[0] -eq 'read' -or ($args[0] -eq 'item' -and $args[1] -eq 'get')) {
                    throw 'forbidden-secret-value'
                }

                throw 'user@example.test session-token vault-id'
            }

            $result = Test-KeldorSecretProvider -Name OnePassword -Detailed

            $result.Success | Should -BeFalse
            $result.Status | Should -Be 'NotAuthenticated'
            ($result.Checks | Where-Object Name -EQ 'VersionAvailable').Success | Should -BeFalse
            ($result.Checks | Where-Object Name -EQ 'Authenticated').Success | Should -BeFalse
            ($result | Out-String) | Should -Not -Match 'user@example.test|session-token|vault-id|forbidden-secret-value'
        }
    }

    It "reports OnePassword authenticated and vault accessible" {
        InModuleScope Keldor {
            Mock Get-Command { [pscustomobject]@{ Name = 'op'; CommandType = 'Function' } } -ParameterFilter {
                $Name -eq 'op'
            }
            Mock op {
                if ($args[0] -eq 'read' -or ($args[0] -eq 'item')) {
                    throw 'forbidden secret operation'
                }

                return 'safe ignored output'
            }

            $result = Test-KeldorSecretProvider -Name OnePassword -Vault DevOps -Detailed

            $result.Success | Should -BeTrue
            ($result.Checks | Where-Object Name -EQ 'VersionAvailable').Success | Should -BeTrue
            ($result.Checks | Where-Object Name -EQ 'Authenticated').Success | Should -BeTrue
            ($result.Checks | Where-Object Name -EQ 'VaultAccessible').Success | Should -BeTrue
        }
    }

    It "reports OnePassword vault unavailable" {
        InModuleScope Keldor {
            Mock Get-Command { [pscustomobject]@{ Name = 'op'; CommandType = 'Function' } } -ParameterFilter {
                $Name -eq 'op'
            }
            Mock op {
                if ($args[0] -eq 'vault') {
                    throw 'vault-id sensitive text'
                }

                return 'safe ignored output'
            }

            $result = Test-KeldorSecretProvider -Name OnePassword -Vault DevOps -Detailed

            $result.Success | Should -BeFalse
            ($result.Checks | Where-Object Name -EQ 'VaultAccessible').Success | Should -BeFalse
            ($result | Out-String) | Should -Not -Match 'vault-id'
        }
    }

    It "reports SecretManagement missing module without terminating" {
        InModuleScope Keldor {
            Mock Get-Module { $null } -ParameterFilter {
                $ListAvailable -and $Name -eq 'Microsoft.PowerShell.SecretManagement'
            }
            Mock Get-Command { $null }

            $result = Test-KeldorSecretProvider -Name SecretManagement -Detailed

            $result.Success | Should -BeFalse
            $result.Status | Should -Be 'NotInstalled'
            ($result.Checks | Where-Object Name -EQ 'ModuleInstalled').Success | Should -BeFalse
        }
    }

    It "reports SecretManagement missing commands" {
        InModuleScope Keldor {
            Mock Get-Module { [pscustomobject]@{ Name = 'Microsoft.PowerShell.SecretManagement' } } -ParameterFilter {
                $ListAvailable -and $Name -eq 'Microsoft.PowerShell.SecretManagement'
            }
            Mock Get-Command { $null }

            $result = Test-KeldorSecretProvider -Name SecretManagement -Detailed

            $result.Success | Should -BeFalse
            ($result.Checks | Where-Object Name -EQ 'CommandsAvailable').Success | Should -BeFalse
        }
    }

    It "reports SecretManagement no vaults registered" {
        InModuleScope Keldor {
            Mock Get-Module { [pscustomobject]@{ Name = 'Microsoft.PowerShell.SecretManagement' } } -ParameterFilter {
                $ListAvailable -and $Name -eq 'Microsoft.PowerShell.SecretManagement'
            }
            Mock Get-Command { [pscustomobject]@{ Name = $Name } } -ParameterFilter {
                $Name -in @('Get-SecretVault', 'Test-SecretVault')
            }
            Mock Get-SecretVault { @() }

            $result = Test-KeldorSecretProvider -Name SecretManagement -Detailed

            $result.Success | Should -BeFalse
            $result.Status | Should -Be 'NotConfigured'
            ($result.Checks | Where-Object Name -EQ 'VaultRegistered').Success | Should -BeFalse
        }
    }

    It "reports requested SecretManagement vault missing" {
        InModuleScope Keldor {
            Mock Get-Module { [pscustomobject]@{ Name = 'Microsoft.PowerShell.SecretManagement' } } -ParameterFilter {
                $ListAvailable -and $Name -eq 'Microsoft.PowerShell.SecretManagement'
            }
            Mock Get-Command { [pscustomobject]@{ Name = $Name } } -ParameterFilter {
                $Name -in @('Get-SecretVault', 'Test-SecretVault')
            }
            Mock Get-SecretVault { [pscustomobject]@{ Name = 'OtherVault' } }

            $result = Test-KeldorSecretProvider -Name SecretManagement -Vault DevOps -Detailed

            $result.Success | Should -BeFalse
            ($result.Checks | Where-Object Name -EQ 'VaultRegistered').Success | Should -BeFalse
        }
    }

    It "reports SecretManagement vault test success and failure without secret operations" {
        InModuleScope Keldor {
            Mock Get-Module { [pscustomobject]@{ Name = 'Microsoft.PowerShell.SecretManagement' } } -ParameterFilter {
                $ListAvailable -and $Name -eq 'Microsoft.PowerShell.SecretManagement'
            }
            Mock Get-Command { [pscustomobject]@{ Name = $Name } } -ParameterFilter {
                $Name -in @('Get-SecretVault', 'Test-SecretVault')
            }
            Mock Get-SecretVault {
                @(
                    [pscustomobject]@{ Name = 'DevOps' }
                    [pscustomobject]@{ Name = 'BrokenVault' }
                )
            }
            Mock Test-SecretVault {
                $Name -eq 'DevOps'
            }
            Mock Get-Secret { throw 'should-not-read-secret' }
            Mock Set-Secret { throw 'should-not-write-secret' }
            Mock Remove-Secret { throw 'should-not-remove-secret' }

            $result = Test-KeldorSecretProvider -Name SecretManagement -Detailed

            $result.Success | Should -BeFalse
            ($result.Checks | Where-Object Name -EQ 'VaultOperational').Count | Should -Be 2
            Assert-MockCalled Get-Secret -Times 0
            Assert-MockCalled Set-Secret -Times 0
            Assert-MockCalled Remove-Secret -Times 0
        }
    }

    It "reports SecretManagement requested vault success" {
        InModuleScope Keldor {
            Mock Get-Module { [pscustomobject]@{ Name = 'Microsoft.PowerShell.SecretManagement' } } -ParameterFilter {
                $ListAvailable -and $Name -eq 'Microsoft.PowerShell.SecretManagement'
            }
            Mock Get-Command { [pscustomobject]@{ Name = $Name } } -ParameterFilter {
                $Name -in @('Get-SecretVault', 'Test-SecretVault')
            }
            Mock Get-SecretVault { [pscustomobject]@{ Name = 'DevOps' } }
            Mock Test-SecretVault { $true }

            $result = Test-KeldorSecretProvider -Name SecretManagement -Vault DevOps -Detailed

            $result.Success | Should -BeTrue
            $result.Vault | Should -Be 'DevOps'
            ($result.Checks | Where-Object Name -EQ 'ProviderOperational').Success | Should -BeTrue
        }
    }
}
