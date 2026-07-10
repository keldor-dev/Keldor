function Get-KeldorSecretProviderOrder {
    [CmdletBinding()]
    param()

    Get-KeldorSecretProviderDefinition |
        Sort-Object -Property Priority |
        Select-Object -ExpandProperty Name
}
