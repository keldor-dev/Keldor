function Get-KeldorSecretProvider {
    <#
.SYNOPSIS
    Gets Keldor secret providers.

.DESCRIPTION
    Gets the secret providers known to Keldor and reports their current availability and capabilities without retrieving secret values.

.PARAMETER Name
    Specifies one or more provider names. Auto is not a provider and is not returned.

.PARAMETER AvailableOnly
    Returns only providers currently available for use.

.PARAMETER Detailed
    Includes additional non-sensitive provider diagnostics and capability information.

.EXAMPLE
    Get-KeldorSecretProvider

    Gets the Keldor secret providers.

.EXAMPLE
    Get-KDSecretProvider -Name SecretManagement -Detailed

    Gets detailed SecretManagement provider information by using the Get-KDSecretProvider alias.

.OUTPUTS
    Keldor.SecretProviderInfo

.NOTES
    Alias: Get-KDSecretProvider

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-KeldorSecretProvider
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-KeldorSecretProvider')]
    [OutputType([pscustomobject])]
    [Alias('Get-KDSecretProvider')]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Name,

        [Parameter()]
        [switch]$AvailableOnly,

        [Parameter()]
        [switch]$Detailed
    )

    process {
        $Definitions = @(Resolve-KeldorSecretProviderDefinition -Name $Name)

        foreach ($Definition in $Definitions) {
            $ProviderInfo = Get-KeldorSecretProviderInfoObject -Definition $Definition -Detailed:$Detailed

            if ($AvailableOnly -and -not $ProviderInfo.Available) {
                continue
            }

            $ProviderInfo
        }
    }
}
