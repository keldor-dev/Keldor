function Get-KeldorSecretProviderDefinition {
    [CmdletBinding()]
    param()

    @(
        [pscustomobject]@{
            Name                = 'OnePassword'
            DisplayName         = '1Password CLI'
            Priority            = 1
            CanRead             = $true
            CanWrite            = $false
            CanRemove           = $true
            SupportsVault       = $true
            SupportsField       = $false
            SupportsSecureInput = $false
        }
        [pscustomobject]@{
            Name                = 'SecretManagement'
            DisplayName         = 'Microsoft.PowerShell.SecretManagement'
            Priority            = 2
            CanRead             = $true
            CanWrite            = $true
            CanRemove           = $true
            SupportsVault       = $true
            SupportsField       = $false
            SupportsSecureInput = $true
        }
        [pscustomobject]@{
            Name                = 'Environment'
            DisplayName         = 'Process environment variables'
            Priority            = 3
            CanRead             = $true
            CanWrite            = $true
            CanRemove           = $true
            SupportsVault       = $false
            SupportsField       = $false
            SupportsSecureInput = $false
        }
    )
}
