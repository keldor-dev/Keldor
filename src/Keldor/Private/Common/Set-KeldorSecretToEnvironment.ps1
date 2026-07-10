function Set-KeldorSecretToEnvironment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [object]$Secret,

        [Parameter()]
        [string]$Field,

        [Parameter()]
        [switch]$Force
    )

    if (-not [string]::IsNullOrWhiteSpace($Field)) {
        throw "The Environment provider does not support the Field parameter."
    }

    $EnvironmentName = Get-KeldorSecretEnvironmentName -Name $Name
    $ExistingValue = [Environment]::GetEnvironmentVariable($EnvironmentName, [EnvironmentVariableTarget]::Process)
    $Action = 'Created'

    if (-not [string]::IsNullOrEmpty($ExistingValue)) {
        if (-not $Force) {
            throw "Secret '$Name' already exists in the Environment provider. Use -Force to replace it."
        }

        $Action = 'Updated'
    }

    $PlainTextSecret = $null

    try {
        if ($Secret -is [System.Security.SecureString]) {
            $PlainTextSecret = ConvertFrom-KeldorSecureString -SecureString $Secret
        } elseif ($Secret -is [string]) {
            $PlainTextSecret = $Secret
        } else {
            throw "Secret must be a string or SecureString."
        }

        [Environment]::SetEnvironmentVariable(
            $EnvironmentName,
            $PlainTextSecret,
            [EnvironmentVariableTarget]::Process
        )
    } finally {
        $PlainTextSecret = $null
    }

    $Action
}
