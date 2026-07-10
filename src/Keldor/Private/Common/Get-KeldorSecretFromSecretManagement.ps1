function Get-KeldorSecretFromSecretManagement {
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
        return $null
    }

    try {
        $GetSecretParameters = @{
            Name              = $Name
            AsPlainText       = $true
            ErrorAction       = 'Stop'
            WarningAction     = 'SilentlyContinue'
            InformationAction = 'SilentlyContinue'
            Verbose           = $false
            Debug             = $false
        }

        if ([string]::IsNullOrWhiteSpace($Vault)) {
            $SecretValue = Get-Secret @GetSecretParameters
        }
        else {
            $GetSecretParameters['Vault'] = $Vault
            $SecretValue = Get-Secret @GetSecretParameters
        }

        if ($null -eq $SecretValue) {
            return $null
        }

        return [string]$SecretValue
    }
    catch {
        return $null
    }
}
