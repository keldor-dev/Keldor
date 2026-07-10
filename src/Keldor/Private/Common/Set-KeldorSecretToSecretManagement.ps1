function Set-KeldorSecretToSecretManagement {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [object]$Secret,

        [Parameter()]
        [string]$Vault,

        [Parameter()]
        [string]$Field,

        [Parameter()]
        [switch]$Force
    )

    if (-not [string]::IsNullOrWhiteSpace($Field)) {
        throw "The SecretManagement provider does not support the Field parameter."
    }

    $SecretManagementModule = Get-Module -ListAvailable -Name 'Microsoft.PowerShell.SecretManagement' -ErrorAction SilentlyContinue
    if ($null -eq $SecretManagementModule) {
        throw "The Microsoft.PowerShell.SecretManagement module is not installed."
    }

    $SetSecretCommand = Get-Command -Name 'Set-Secret' -ErrorAction SilentlyContinue
    if ($null -eq $SetSecretCommand) {
        throw "The Set-Secret command is not available."
    }

    $GetSecretInfoCommand = Get-Command -Name 'Get-SecretInfo' -ErrorAction SilentlyContinue
    if ($null -eq $GetSecretInfoCommand) {
        throw "The Get-SecretInfo command is not available for safe existence detection."
    }

    $GetSecretInfoParameters = @{
        Name              = $Name
        ErrorAction       = 'SilentlyContinue'
        WarningAction     = 'SilentlyContinue'
        InformationAction = 'SilentlyContinue'
        Verbose           = $false
        Debug             = $false
    }

    if (-not [string]::IsNullOrWhiteSpace($Vault)) {
        $GetSecretInfoParameters['Vault'] = $Vault
    }

    $SecretExists = $null -ne (Get-SecretInfo @GetSecretInfoParameters)

    if ($SecretExists -and -not $Force) {
        throw "Secret '$Name' already exists in the SecretManagement provider. Use -Force to replace it."
    }

    $SetSecretParameters = @{
        Name              = $Name
        Secret            = $Secret
        ErrorAction       = 'Stop'
        WarningAction     = 'SilentlyContinue'
        InformationAction = 'SilentlyContinue'
        Verbose           = $false
        Debug             = $false
    }

    if (-not [string]::IsNullOrWhiteSpace($Vault)) {
        $SetSecretParameters['Vault'] = $Vault
    }

    try {
        Set-Secret @SetSecretParameters | Out-Null
    } catch {
        throw "Unable to set secret '$Name' using the SecretManagement provider."
    }

    if ($SecretExists) {
        return 'Updated'
    }

    'Created'
}
