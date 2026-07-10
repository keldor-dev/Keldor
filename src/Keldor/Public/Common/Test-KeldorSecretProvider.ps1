function Test-KeldorSecretProvider {
<#
.SYNOPSIS
    Tests Keldor secret providers.

.DESCRIPTION
    Performs safe, read-only operational checks against Keldor secret providers.
    This differs from Get-KeldorSecretProvider, which reports passive metadata and availability.
    Test-KeldorSecretProvider never retrieves, creates, modifies, or removes secret values.

.PARAMETER Name
    Specifies one or more provider names. Auto is provider selection behavior and is not a provider.

.PARAMETER Vault
    Specifies a provider vault to validate where the provider supports vaults.

.PARAMETER Detailed
    Includes individual non-sensitive check results.

.PARAMETER Quiet
    Returns only a Boolean value. Returns true only when every requested provider passes all required checks.

.EXAMPLE
    Test-KeldorSecretProvider

    Tests all known Keldor secret providers.

.EXAMPLE
    Test-KeldorSecretProvider -Name OnePassword

    Tests the OnePassword provider.

.EXAMPLE
    Test-KeldorSecretProvider -Name OnePassword, SecretManagement

    Tests multiple providers.

.EXAMPLE
    Test-KeldorSecretProvider -Name SecretManagement -Vault DevOps

    Tests the DevOps SecretManagement vault without enumerating secrets.

.EXAMPLE
    Test-KeldorSecretProvider -Name OnePassword -Detailed | Format-List *

    Shows detailed non-sensitive OnePassword provider check results.

.EXAMPLE
    if (Test-KeldorSecretProvider -Name OnePassword -Quiet) {
        '1Password is ready.'
    }

    Uses Boolean output for control flow.

.EXAMPLE
    'OnePassword', 'Environment' | Test-KeldorSecretProvider

    Tests providers from pipeline input.

.EXAMPLE
    Test-KDSecretProvider -Name SecretManagement

    Tests the SecretManagement provider by using the Test-KDSecretProvider alias.

.OUTPUTS
    Keldor.SecretProviderTestResult. Returns System.Boolean when Quiet is specified.

.NOTES
    Alias: Test-KDSecretProvider

.LINK
    https://docs.keldor.dev/powershell/keldor/Test-KeldorSecretProvider
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Test-KeldorSecretProvider')]
    [OutputType([pscustomobject], [bool])]
    [Alias('Test-KDSecretProvider')]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Vault,

        [Parameter()]
        [switch]$Detailed,

        [Parameter()]
        [switch]$Quiet
    )

    begin {
        if ($Detailed -and $Quiet) {
            throw "Parameters Detailed and Quiet cannot be used together."
        }

        $RequestedProviderNames = @()
    }

    process {
        if ($Name) {
            $RequestedProviderNames += $Name
        }
    }

    end {
        $Definitions = @(Resolve-KeldorSecretProviderDefinition -Name $RequestedProviderNames)

        if (-not [string]::IsNullOrWhiteSpace($Vault)) {
            foreach ($Definition in $Definitions) {
                if (-not $Definition.SupportsVault) {
                    throw "Parameter -Vault is not supported by provider '$($Definition.Name)'."
                }
            }
        }

        $Results = @()
        foreach ($Definition in $Definitions) {
            $Results += Test-KeldorSecretProviderByDefinition -Definition $Definition -Vault $Vault -Detailed:$Detailed
        }

        if ($Quiet) {
            return -not ($Results | Where-Object { -not $_.Success })
        }

        $Results
    }
}
