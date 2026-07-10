function Resolve-KeldorSecretProviderDefinition {
    [OutputType([object[]])]
    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]]$Name
    )

    $Definitions = @(Get-KeldorSecretProviderDefinition | Sort-Object -Property Priority)

    if (-not $Name) {
        return $Definitions
    }

    $SelectedDefinitions = @()
    foreach ($ProviderName in $Name) {
        if ($ProviderName -eq 'Auto') {
            throw "Auto is provider selection behavior, not a secret provider."
        }

        $ProviderMatches = @($Definitions | Where-Object { $_.Name -ieq $ProviderName })
        if ($ProviderMatches.Count -eq 0) {
            throw "Secret provider '$ProviderName' was not found."
        }

        $SelectedDefinitions += $ProviderMatches
    }

    $SelectedDefinitions | Sort-Object -Property Priority -Unique
}
