function Set-KeldorSecret {
<#
.SYNOPSIS
    Sets a Keldor secret.

.DESCRIPTION
    Sets a secret using a single writable Keldor secret provider.
    Auto provider selection chooses one provider in priority order and does not fall back after a write attempt.

.PARAMETER Name
    Specifies the secret or provider item name.

.PARAMETER Secret
    Specifies the secret value as a string or SecureString.

.PARAMETER Vault
    Specifies the optional provider vault or container name.

.PARAMETER Provider
    Specifies the secret provider to use. Auto selects one writable provider in priority order.

.PARAMETER Field
    Specifies a provider field to update. Only providers that support named fields accept this parameter.

.PARAMETER Force
    Replaces an existing secret when the provider supports existence checks.

.PARAMETER PassThru
    Returns a non-sensitive result object describing the operation.

.EXAMPLE
    Set-KeldorSecret -Name GitHubToken -Secret $Token -Provider SecretManagement -Vault DevOps -Force

    Stores the GitHubToken secret in the DevOps SecretManagement vault.

.EXAMPLE
    Set-KDSecret -Name 'GitHub Token' -Secret $Token -Provider Environment -PassThru

    Sets the process-scoped KELDOR_SECRET_GITHUB_TOKEN environment variable by using the Set-KDSecret alias.

.OUTPUTS
    None. Returns Keldor.SecretWriteResult when PassThru is specified.

.NOTES
    Alias: Set-KDSecret
    Environment provider values are process scoped and disappear when the process exits.

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-KeldorSecret
#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-KeldorSecret')]
    [OutputType([pscustomobject])]
    [Alias('Set-KDSecret')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({
            if ([string]::IsNullOrWhiteSpace($_)) {
                throw "Name cannot be null, empty, or whitespace."
            }

            $true
        })]
        [string]$Name,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNull()]
        [object]$Secret,

        [Parameter(Position = 2)]
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
        if (-not ($Secret -is [string]) -and -not ($Secret -is [System.Security.SecureString])) {
            throw "Secret must be a string or SecureString."
        }

        $SelectedProvider = $Provider
        if ($Provider -eq 'Auto') {
            foreach ($ProviderDefinition in Get-KeldorSecretProviderDefinition | Sort-Object -Property Priority) {
                if (-not $ProviderDefinition.CanWrite) {
                    continue
                }

                if ($ProviderDefinition.Name -eq 'SecretManagement') {
                    $SecretManagementModule = Get-Module -ListAvailable -Name 'Microsoft.PowerShell.SecretManagement' -ErrorAction SilentlyContinue
                    $SecretManagementCommand = Get-Command -Name 'Set-Secret' -ErrorAction SilentlyContinue

                    if ($null -ne $SecretManagementModule -and $null -ne $SecretManagementCommand) {
                        $SelectedProvider = $ProviderDefinition.Name
                        break
                    }
                }
                elseif ($ProviderDefinition.Name -eq 'Environment') {
                    $SelectedProvider = $ProviderDefinition.Name
                    break
                }
            }
        }

        $Target = "secret '$Name' using provider '$SelectedProvider'"
        $Action = 'create or update secret'

        if (-not $PSCmdlet.ShouldProcess($Target, $Action)) {
            return
        }

        $ProviderAction = switch ($SelectedProvider) {
            'OnePassword' {
                Set-KeldorSecretToOnePassword -Name $Name -Secret $Secret -Vault $Vault -Field $Field -Force:$Force
            }
            'SecretManagement' {
                Set-KeldorSecretToSecretManagement -Name $Name -Secret $Secret -Vault $Vault -Field $Field -Force:$Force
            }
            'Environment' {
                Set-KeldorSecretToEnvironment -Name $Name -Secret $Secret -Field $Field -Force:$Force
            }
            default {
                throw "Provider '$SelectedProvider' is not supported for secret writes."
            }
        }

        if ($PassThru) {
            [pscustomobject]@{
                PSTypeName = 'Keldor.SecretWriteResult'
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
