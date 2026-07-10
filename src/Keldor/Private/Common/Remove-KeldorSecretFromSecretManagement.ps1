function Remove-KeldorSecretFromSecretManagement {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter()]
        [string]$Vault,

        [Parameter()]
        [string]$Field
    )

    if (-not [string]::IsNullOrWhiteSpace($Field)) {
        throw "The SecretManagement provider does not support the Field parameter."
    }

    $SecretManagementModule = Get-Module -ListAvailable -Name 'Microsoft.PowerShell.SecretManagement' -ErrorAction SilentlyContinue
    if ($null -eq $SecretManagementModule) {
        throw "The Microsoft.PowerShell.SecretManagement module is not installed."
    }

    $RemoveSecretCommand = Get-Command -Name 'Remove-Secret' -ErrorAction SilentlyContinue
    if ($null -eq $RemoveSecretCommand) {
        throw "The Remove-Secret command is not available."
    }

    if (-not (Test-KeldorSecretInSecretManagement -Name $Name -Vault $Vault)) {
        throw "Secret '$Name' was not found in the SecretManagement provider."
    }

    $RemoveSecretParameters = @{
        Name              = $Name
        ErrorAction       = 'Stop'
        WarningAction     = 'SilentlyContinue'
        InformationAction = 'SilentlyContinue'
        Verbose           = $false
        Debug             = $false
    }

    if (-not [string]::IsNullOrWhiteSpace($Vault)) {
        $RemoveSecretParameters['Vault'] = $Vault
    }

    try {
        Remove-Secret @RemoveSecretParameters | Out-Null
    } catch {
        throw "Unable to remove secret '$Name' using the SecretManagement provider."
    }

    'Removed'
}
