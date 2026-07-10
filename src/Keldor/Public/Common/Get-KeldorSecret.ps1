function Get-KeldorSecret {
    <#
.SYNOPSIS
    Gets a Keldor secret.

.DESCRIPTION
    Gets a plaintext secret string from the first available configured provider.
    Auto provider selection tries OnePassword CLI, SecretManagement, and environment variables in that order.

.PARAMETER Name
    Specifies the secret or item name.

.PARAMETER Vault
    Specifies the optional provider vault name.

.PARAMETER Provider
    Specifies the secret provider to use. Auto tries all supported providers in priority order.

.PARAMETER AsPlainText
    Returns the secret as plaintext. This switch is reserved for future compatibility because all current providers return plaintext strings.

.EXAMPLE
    Get-KeldorSecret -Name GitHubToken

    Gets the GitHubToken secret using the first configured provider that can retrieve it.

.EXAMPLE
    Get-KDSecret -Name 'GitHub Token' -Provider Environment

    Gets the KELDOR_SECRET_GITHUB_TOKEN environment variable by using the Get-KDSecret alias.

.OUTPUTS
    System.String

.NOTES
    Alias: Get-KDSecret

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-KeldorSecret
#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSReviewUnusedParameter',
        'AsPlainText',
        Justification = 'Reserved for future compatibility because all current providers return plaintext strings.'
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-KeldorSecret')]
    [OutputType([string])]
    [Alias('Get-KDSecret')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Vault,

        [Parameter()]
        [ValidateSet('Auto', 'OnePassword', 'SecretManagement', 'Environment')]
        [string]$Provider = 'Auto',

        [Parameter()]
        [switch]$AsPlainText
    )

    process {
        $ProviderOrder = switch ($Provider) {
            'Auto' { @(Get-KeldorSecretProviderOrder) }
            default { @($Provider) }
        }

        foreach ($CurrentProvider in $ProviderOrder) {
            try {
                $SecretValue = switch ($CurrentProvider) {
                    'OnePassword' {
                        Get-KeldorSecretFromOnePassword -Name $Name -Vault $Vault
                    }
                    'SecretManagement' {
                        Get-KeldorSecretFromSecretManagement -Name $Name -Vault $Vault
                    }
                    'Environment' {
                        Get-KeldorSecretFromEnvironment -Name $Name
                    }
                }

                if ($null -ne $SecretValue) {
                    return [string]$SecretValue
                }
            } catch {
                continue
            }
        }

        throw "Unable to retrieve secret '$Name' using any configured provider."
    }
}
