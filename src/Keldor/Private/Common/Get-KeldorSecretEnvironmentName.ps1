function Get-KeldorSecretEnvironmentName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    'KELDOR_SECRET_{0}' -f ($Name.ToUpperInvariant() -replace '[\s-]', '_')
}
