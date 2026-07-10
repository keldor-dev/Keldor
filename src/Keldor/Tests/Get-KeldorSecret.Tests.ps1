Describe "Get-KeldorSecret" {
    BeforeAll {
        $ModuleRoot = Split-Path -Parent $PSScriptRoot
        $ManifestPath = Join-Path $ModuleRoot 'Keldor.psd1'

        Import-Module $ManifestPath -Force

        $script:OriginalGitHubToken = [Environment]::GetEnvironmentVariable('KELDOR_SECRET_GITHUB_TOKEN')
        $script:OriginalMissingSecret = [Environment]::GetEnvironmentVariable('KELDOR_SECRET_MISSING_SECRET')
        $script:OriginalPrivateToken = [Environment]::GetEnvironmentVariable('KELDOR_SECRET_PRIVATE_TOKEN')
    }

    AfterEach {
        [Environment]::SetEnvironmentVariable('KELDOR_SECRET_GITHUB_TOKEN', $script:OriginalGitHubToken)
        [Environment]::SetEnvironmentVariable('KELDOR_SECRET_MISSING_SECRET', $script:OriginalMissingSecret)
        [Environment]::SetEnvironmentVariable('KELDOR_SECRET_PRIVATE_TOKEN', $script:OriginalPrivateToken)
    }

    It "exports the primary command and alias" {
        (Get-Command -Name Get-KeldorSecret -Module Keldor).Name | Should -Be 'Get-KeldorSecret'

        $alias = Get-Alias -Name Get-KDSecret
        $alias.Definition | Should -Be 'Get-KeldorSecret'
    }

    It "documents the alias in comment-based help" {
        $help = Get-Help Get-KeldorSecret -Full

        $help.alertSet.alert.Text | Should -Match 'Alias: Get-KDSecret'
        (Get-Command Get-KeldorSecret).HelpUri | Should -Be 'https://docs.keldor.dev/powershell/keldor/Get-KeldorSecret'
    }

    It "gets a secret from OnePassword when Auto finds it first" {
        InModuleScope Keldor {
            Mock Get-KeldorSecretFromOnePassword { 'from-onepassword' }
            Mock Get-KeldorSecretFromSecretManagement { 'from-secretmanagement' }
            Mock Get-KeldorSecretFromEnvironment { 'from-environment' }

            Get-KeldorSecret -Name GitHubToken | Should -Be 'from-onepassword'

            Assert-MockCalled Get-KeldorSecretFromOnePassword -Times 1 -Exactly
            Assert-MockCalled Get-KeldorSecretFromSecretManagement -Times 0
            Assert-MockCalled Get-KeldorSecretFromEnvironment -Times 0
        }
    }

    It "uses Auto provider fallback order" {
        InModuleScope Keldor {
            $script:ProviderCalls = @()

            Mock Get-KeldorSecretFromOnePassword {
                $script:ProviderCalls += 'OnePassword'
                return $null
            }
            Mock Get-KeldorSecretFromSecretManagement {
                $script:ProviderCalls += 'SecretManagement'
                return $null
            }
            Mock Get-KeldorSecretFromEnvironment {
                $script:ProviderCalls += 'Environment'
                return 'from-environment'
            }

            Get-KeldorSecret -Name GitHubToken | Should -Be 'from-environment'

            $script:ProviderCalls | Should -Be @('OnePassword', 'SecretManagement', 'Environment')
        }
    }

    It "uses only the explicitly selected provider" {
        InModuleScope Keldor {
            Mock Get-KeldorSecretFromOnePassword { 'from-onepassword' }
            Mock Get-KeldorSecretFromSecretManagement { 'from-secretmanagement' }
            Mock Get-KeldorSecretFromEnvironment { 'from-environment' }

            Get-KeldorSecret -Name GitHubToken -Provider SecretManagement | Should -Be 'from-secretmanagement'

            Assert-MockCalled Get-KeldorSecretFromOnePassword -Times 0
            Assert-MockCalled Get-KeldorSecretFromSecretManagement -Times 1 -Exactly
            Assert-MockCalled Get-KeldorSecretFromEnvironment -Times 0
        }
    }

    It "passes Vault to providers that support vaults" {
        InModuleScope Keldor {
            Mock Get-KeldorSecretFromOnePassword { 'from-onepassword' } -ParameterFilter {
                $Name -eq 'GitHubToken' -and $Vault -eq 'Engineering'
            }

            Get-KeldorSecret -Name GitHubToken -Vault Engineering -Provider OnePassword | Should -Be 'from-onepassword'

            Assert-MockCalled Get-KeldorSecretFromOnePassword -Times 1 -Exactly
        }
    }

    It "allows the alias to invoke the same implementation as the primary cmdlet" {
        InModuleScope Keldor {
            Mock Get-KeldorSecretFromEnvironment { 'from-alias' } -ParameterFilter {
                $Name -eq 'GitHubToken'
            }

            Get-KDSecret -Name GitHubToken -Provider Environment | Should -Be 'from-alias'

            Assert-MockCalled Get-KeldorSecretFromEnvironment -Times 1 -Exactly
        }
    }

    It "returns environment secrets using normalized environment variable names" {
        [Environment]::SetEnvironmentVariable('KELDOR_SECRET_GITHUB_TOKEN', 'from-environment-variable')

        InModuleScope Keldor {
            Get-KeldorSecret -Name 'GitHub Token' -Provider Environment | Should -Be 'from-environment-variable'
        }
    }

    It "returns null from OnePassword when the CLI is missing" {
        InModuleScope Keldor {
            Mock Get-Command { $null } -ParameterFilter {
                $Name -eq 'op'
            }

            Get-KeldorSecretFromOnePassword -Name GitHubToken | Should -BeNullOrEmpty
        }
    }

    It "trims trailing newlines from OnePassword values" {
        InModuleScope Keldor {
            Mock Get-Command { [pscustomobject]@{ Name = 'op' } } -ParameterFilter {
                $Name -eq 'op'
            }
            Mock op { "from-onepassword`n" }

            Get-KeldorSecretFromOnePassword -Name GitHubToken -Vault Engineering | Should -Be 'from-onepassword'

            Assert-MockCalled op -Times 1 -Exactly -ParameterFilter {
                $args[0] -eq 'read' -and $args[1] -eq 'op://Engineering/GitHubToken/password'
            }
        }
    }

    It "returns null from SecretManagement when the module is missing" {
        InModuleScope Keldor {
            Mock Get-Module { $null } -ParameterFilter {
                $ListAvailable -and $Name -eq 'Microsoft.PowerShell.SecretManagement'
            }

            Get-KeldorSecretFromSecretManagement -Name GitHubToken | Should -BeNullOrEmpty
        }
    }

    It "gets a secret from SecretManagement with a vault" {
        InModuleScope Keldor {
            Mock Get-Module { [pscustomobject]@{ Name = 'Microsoft.PowerShell.SecretManagement' } } -ParameterFilter {
                $ListAvailable -and $Name -eq 'Microsoft.PowerShell.SecretManagement'
            }
            Mock Get-Secret { 'from-secretmanagement' } -ParameterFilter {
                $Name -eq 'GitHubToken' -and $Vault -eq 'Engineering' -and $AsPlainText
            }

            Get-KeldorSecretFromSecretManagement -Name GitHubToken -Vault Engineering | Should -Be 'from-secretmanagement'

            Assert-MockCalled Get-Secret -Times 1 -Exactly
        }
    }

    It "throws one sanitized exception when all providers fail" {
        InModuleScope Keldor {
            Mock Get-KeldorSecretFromOnePassword { $null }
            Mock Get-KeldorSecretFromSecretManagement { $null }
            Mock Get-KeldorSecretFromEnvironment { $null }

            { Get-KeldorSecret -Name MissingSecret } |
                Should -Throw "Unable to retrieve secret 'MissingSecret' using any configured provider."
        }
    }

    It "does not leak provider error details in the final exception" {
        InModuleScope Keldor {
            Mock Get-KeldorSecretFromOnePassword { throw 'super-secret-value' }
            Mock Get-KeldorSecretFromSecretManagement { $null }
            Mock Get-KeldorSecretFromEnvironment { $null }

            try {
                Get-KeldorSecret -Name PrivateToken -Provider Auto
            } catch {
                $_.Exception.Message | Should -Not -Match 'super-secret-value'
                $_.Exception.Message | Should -Be "Unable to retrieve secret 'PrivateToken' using any configured provider."
            }
        }
    }
}
