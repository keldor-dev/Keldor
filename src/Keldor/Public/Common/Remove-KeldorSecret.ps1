function Remove-KeldorSecret {
<#
.SYNOPSIS
    Removes a Keldor secret.

.DESCRIPTION
    Removes a secret from exactly one Keldor secret provider.
    Auto provider selection detects where the secret exists and fails if the target is ambiguous.

.PARAMETER Name
    Specifies the secret or provider item name.

.PARAMETER Vault
    Specifies the optional provider vault or container name.

.PARAMETER Provider
    Specifies the secret provider to use. Auto selects one provider only when the secret exists in exactly one provider.

.PARAMETER Field
    Specifies a provider field to remove. Only providers that support field-level removal accept this parameter.

.PARAMETER Force
    Suppresses interactive confirmation prompts while still honoring ShouldProcess and WhatIf.

.PARAMETER PassThru
    Returns a non-sensitive result object describing the removal.

.EXAMPLE
    Remove-KeldorSecret -Name GitHubToken -Provider SecretManagement -Vault DevOps -Force

    Removes the GitHubToken secret from the DevOps SecretManagement vault.

.EXAMPLE
    Remove-KDSecret -Name 'GitHub Token' -Provider Environment -PassThru -Force

    Removes the process-scoped KELDOR_SECRET_GITHUB_TOKEN environment variable by using the Remove-KDSecret alias.

.OUTPUTS
    None. Returns Keldor.SecretRemovalResult when PassThru is specified.

.NOTES
    Alias: Remove-KDSecret
    Environment provider removals are process scoped and do not remove values configured outside the current PowerShell process.

.LINK
    https://docs.keldor.dev/powershell/keldor/Remove-KeldorSecret
#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High', HelpUri = 'https://docs.keldor.dev/powershell/keldor/Remove-KeldorSecret')]
    [OutputType([pscustomobject])]
    [Alias('Remove-KDSecret')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({
            if ([string]::IsNullOrWhiteSpace($_)) {
                throw "Name cannot be null, empty, or whitespace."
            }

            $true
        })]
        [string]$Name,

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Vault,

        [Parameter()]
        [ValidateSet('Auto', 'OnePassword', 'SecretManagement', 'Environment')]
        [string]$Provider = 'Auto',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Field,

        [Parameter()]
        [switch]$Force,

        [Parameter()]
        [switch]$PassThru
    )

    process {
        $SelectedProvider = $Provider
        if ($Provider -eq 'Auto') {
            $ProviderMatches = @()

            foreach ($ProviderName in Get-KeldorSecretProviderOrder) {
                $ProviderExists = switch ($ProviderName) {
                    'OnePassword' {
                        Test-KeldorSecretInOnePassword -Name $Name -Vault $Vault
                    }
                    'SecretManagement' {
                        Test-KeldorSecretInSecretManagement -Name $Name -Vault $Vault
                    }
                    'Environment' {
                        Test-KeldorSecretInEnvironment -Name $Name
                    }
                }

                if ($ProviderExists) {
                    $ProviderMatches += $ProviderName
                }
            }

            if ($ProviderMatches.Count -gt 1) {
                throw "Secret '$Name' exists in more than one provider. Specify -Provider explicitly."
            }

            if ($ProviderMatches.Count -eq 0) {
                throw "Secret '$Name' was not found in any configured provider."
            }

            $SelectedProvider = $ProviderMatches[0]
        }

        if ($Force) {
            $ConfirmPreference = 'None'
        }

        if ([string]::IsNullOrWhiteSpace($Field)) {
            $Target = "secret '$Name' using provider '$SelectedProvider'"
            $Action = 'remove secret'
        }
        else {
            $Target = "field '$Field' on secret '$Name' using provider '$SelectedProvider'"
            $Action = 'remove secret field'
        }

        if (-not $PSCmdlet.ShouldProcess($Target, $Action)) {
            return
        }

        $ProviderAction = switch ($SelectedProvider) {
            'OnePassword' {
                Remove-KeldorSecretFromOnePassword -Name $Name -Vault $Vault -Field $Field
            }
            'SecretManagement' {
                Remove-KeldorSecretFromSecretManagement -Name $Name -Vault $Vault -Field $Field
            }
            'Environment' {
                Remove-KeldorSecretFromEnvironment -Name $Name -Field $Field
            }
            default {
                throw "Provider '$SelectedProvider' is not supported for secret removals."
            }
        }

        if ($PassThru) {
            [pscustomobject]@{
                PSTypeName = 'Keldor.SecretRemovalResult'
                Name       = $Name
                Provider   = $SelectedProvider
                Vault      = $Vault
                Field      = if ([string]::IsNullOrWhiteSpace($Field)) { $null } else { $Field }
                Action     = $ProviderAction
                Success    = $true
            }
        }
    }
}
