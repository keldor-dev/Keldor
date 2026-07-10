function Remove-KeldorSecretFromEnvironment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter()]
        [string]$Field
    )

    if (-not [string]::IsNullOrWhiteSpace($Field)) {
        throw "The Environment provider does not support the Field parameter."
    }

    if (-not (Test-KeldorSecretInEnvironment -Name $Name)) {
        throw "Secret '$Name' was not found in the Environment provider."
    }

    $EnvironmentName = Get-KeldorSecretEnvironmentName -Name $Name
    [Environment]::SetEnvironmentVariable(
        $EnvironmentName,
        $null,
        [EnvironmentVariableTarget]::Process
    )

    'Removed'
}
