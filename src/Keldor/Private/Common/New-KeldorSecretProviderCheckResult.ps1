function New-KeldorSecretProviderCheckResult {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'This helper creates an in-memory result object and does not change system state.'
    )]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [bool]$Success,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Passed', 'Failed', 'Skipped', 'NotTested')]
        [string]$Status,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $true)]
        [timespan]$Duration
    )

    [pscustomobject]@{
        PSTypeName = 'Keldor.SecretProviderCheckResult'
        Name       = $Name
        Success    = $Success
        Status     = $Status
        Message    = $Message
        Duration   = $Duration
    }
}
