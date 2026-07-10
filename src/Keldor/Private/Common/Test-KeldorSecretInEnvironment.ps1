function Test-KeldorSecretInEnvironment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    $EnvironmentName = Get-KeldorSecretEnvironmentName -Name $Name
    $ExistingValue = [Environment]::GetEnvironmentVariable($EnvironmentName, [EnvironmentVariableTarget]::Process)

    -not [string]::IsNullOrEmpty($ExistingValue)
}
