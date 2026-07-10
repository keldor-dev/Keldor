function Get-KeldorSecretFromEnvironment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    $EnvironmentName = 'KELDOR_SECRET_{0}' -f ($Name.ToUpperInvariant() -replace '[\s-]', '_')
    $SecretValue = [Environment]::GetEnvironmentVariable($EnvironmentName)

    if ([string]::IsNullOrEmpty($SecretValue)) {
        return $null
    }

    return $SecretValue
}
