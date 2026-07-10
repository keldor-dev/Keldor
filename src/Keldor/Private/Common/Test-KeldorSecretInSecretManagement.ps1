function Test-KeldorSecretInSecretManagement {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter()]
        [string]$Vault
    )

    $SecretManagementModule = Get-Module -ListAvailable -Name 'Microsoft.PowerShell.SecretManagement' -ErrorAction SilentlyContinue
    if ($null -eq $SecretManagementModule) {
        return $false
    }

    $GetSecretInfoCommand = Get-Command -Name 'Get-SecretInfo' -ErrorAction SilentlyContinue
    if ($null -eq $GetSecretInfoCommand) {
        return $false
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

    $null -ne (Get-SecretInfo @GetSecretInfoParameters)
}
