function Get-KeldorSecretFromEnvironment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    $EnvironmentName = Get-KeldorSecretEnvironmentName -Name $Name
    $SecretValue = [Environment]::GetEnvironmentVariable($EnvironmentName)

    if ([string]::IsNullOrEmpty($SecretValue)) {
        return $null
    }

    return $SecretValue
}
