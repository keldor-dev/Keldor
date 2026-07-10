Describe "Get-KeldorSecretProvider" {
    BeforeAll {
        $ModuleRoot = Split-Path -Parent $PSScriptRoot
        $ManifestPath = Join-Path $ModuleRoot 'Keldor.psd1'

        Import-Module $ManifestPath -Force
    }

    It "exports the primary command and alias" {
        (Get-Command -Name Get-KeldorSecretProvider -Module Keldor).Name | Should -Be 'Get-KeldorSecretProvider'

        $alias = Get-Alias -Name Get-KDSecretProvider
        $alias.Definition | Should -Be 'Get-KeldorSecretProvider'
    }

    It "documents the alias in comment-based help" {
        $help = Get-Help Get-KeldorSecretProvider -Full

        $help.alertSet.alert.Text | Should -Match 'Alias: Get-KDSecretProvider'
        (Get-Command Get-KeldorSecretProvider).HelpUri | Should -Be 'https://docs.keldor.dev/powershell/keldor/Get-KeldorSecretProvider'
    }

    It "returns known providers in Get-KeldorSecret Auto priority order without Auto as a provider" {
        InModuleScope Keldor {
            Mock Get-Command { $null }
            Mock Get-Module { $null }

            $providers = @(Get-KeldorSecretProvider)

            $providers.Name | Should -Be @('OnePassword', 'SecretManagement', 'Environment')
            $providers.Priority | Should -Be @(1, 2, 3)
            $providers.Name | Should -Not -Contain 'Auto'
            $providers[0].PSTypeNames[0] | Should -Be 'Keldor.SecretProviderInfo'
        }
    }

    It "uses the shared provider order in Get-KeldorSecret Auto selection" {
        InModuleScope Keldor {
            $script:ProviderCalls = @()

            Mock Get-KeldorSecretProviderOrder { @('Environment', 'SecretManagement', 'OnePassword') }
            Mock Get-KeldorSecretFromEnvironment {
                $script:ProviderCalls += 'Environment'
                return $null
            }
            Mock Get-KeldorSecretFromSecretManagement {
                $script:ProviderCalls += 'SecretManagement'
                return 'from-secretmanagement'
            }
            Mock Get-KeldorSecretFromOnePassword {
                $script:ProviderCalls += 'OnePassword'
                return 'from-onepassword'
            }

            Get-KeldorSecret -Name GitHubToken | Should -Be 'from-secretmanagement'
            $script:ProviderCalls | Should -Be @('Environment', 'SecretManagement')
        }
    }

    It "filters providers by case-insensitive name" {
        InModuleScope Keldor {
            Mock Get-Command { $null }
            Mock Get-Module { $null }

            $provider = Get-KeldorSecretProvider -Name secretmanagement

            $provider.Name | Should -Be 'SecretManagement'
        }
    }

    It "accepts provider names from the pipeline" {
        InModuleScope Keldor {
            Mock Get-Command { $null }
            Mock Get-Module { $null }

            $providers = @('Environment', 'OnePassword') | Get-KeldorSecretProvider

            $providers.Name | Should -Be @('Environment', 'OnePassword')
        }
    }

    It "rejects Auto because it is not a provider" {
        InModuleScope Keldor {
            { Get-KeldorSecretProvider -Name Auto } |
                Should -Throw "Auto is provider selection behavior, not a secret provider."
        }
    }

    It "throws for unknown provider names" {
        InModuleScope Keldor {
            { Get-KeldorSecretProvider -Name UnknownProvider } |
                Should -Throw "Secret provider 'UnknownProvider' was not found."
        }
    }

    It "returns only available providers when AvailableOnly is specified" {
        InModuleScope Keldor {
            Mock Get-Command { $null }
            Mock Get-Module { $null }

            $providers = @(Get-KeldorSecretProvider -AvailableOnly)

            $providers.Name | Should -Be @('Environment')
        }
    }

    It "reports detailed Environment provider metadata without enumerating variables" {
        InModuleScope Keldor {
            $provider = Get-KeldorSecretProvider -Name Environment -Detailed

            $provider.Name | Should -Be 'Environment'
            $provider.Installed | Should -BeTrue
            $provider.Available | Should -BeTrue
            $provider.Scope | Should -Be 'Process'
            $provider.Prefix | Should -Be 'KELDOR_SECRET_'
            $provider.Status | Should -Be 'Ready'
        }
    }

    It "reports OnePassword installed but unauthenticated separately" {
        InModuleScope Keldor {
            Mock Get-Command { [pscustomobject]@{ Name = 'op'; Source = '/usr/local/bin/op'; CommandType = 'Application' } } -ParameterFilter {
                $Name -eq 'op'
            }
            Mock op {
                if ($args[0] -eq '--version') {
                    return '2.30.0'
                }

                throw 'not signed in'
            }

            $provider = Get-KeldorSecretProvider -Name OnePassword -Detailed

            $provider.Installed | Should -BeTrue
            $provider.Authenticated | Should -BeFalse
            $provider.Available | Should -BeFalse
            $provider.Version | Should -Be '2.30.0'
            $provider.CommandPath | Should -Be '/usr/local/bin/op'
            $provider.Status | Should -Be 'NotAuthenticated'
            $provider.StatusReason | Should -Not -Match 'not signed in'
        }
    }

    It "reports SecretManagement availability from module, command, and vault state without reading secrets" {
        InModuleScope Keldor {
            Mock Get-Module { [pscustomobject]@{ Name = 'Microsoft.PowerShell.SecretManagement'; Version = [version]'1.1.2' } } -ParameterFilter {
                $ListAvailable -and $Name -eq 'Microsoft.PowerShell.SecretManagement'
            }
            Mock Get-Command { [pscustomobject]@{ Name = $Name } } -ParameterFilter {
                $Name -in @('Get-Secret', 'Set-Secret', 'Remove-Secret', 'Get-SecretVault', 'Get-SecretInfo')
            }
            Mock Get-SecretVault { [pscustomobject]@{ Name = 'DevOps'; IsDefault = $true } }
            Mock Get-Secret { throw 'should-not-read-secret' }
            Mock Set-Secret { throw 'should-not-write-secret' }
            Mock Remove-Secret { throw 'should-not-remove-secret' }

            $provider = Get-KeldorSecretProvider -Name SecretManagement -Detailed

            $provider.Installed | Should -BeTrue
            $provider.Available | Should -BeTrue
            $provider.ModuleName | Should -Be 'Microsoft.PowerShell.SecretManagement'
            $provider.ModuleVersion | Should -Be '1.1.2'
            $provider.HasVault | Should -BeTrue
            $provider.HasDefaultVault | Should -BeTrue
            $provider.Status | Should -Be 'Ready'
            Assert-MockCalled Get-Secret -Times 0
            Assert-MockCalled Set-Secret -Times 0
            Assert-MockCalled Remove-Secret -Times 0
        }
    }

    It "keeps detailed-only properties out of default provider output" {
        InModuleScope Keldor {
            Mock Get-Command { $null }
            Mock Get-Module { $null }

            $provider = Get-KeldorSecretProvider -Name Environment

            $provider.PSObject.Properties.Name | Should -Not -Contain 'Prefix'
            $provider.PSObject.Properties.Name | Should -Not -Contain 'CommandPath'
            $provider.PSObject.Properties.Name | Should -Not -Contain 'ModuleVersion'
        }
    }
}
