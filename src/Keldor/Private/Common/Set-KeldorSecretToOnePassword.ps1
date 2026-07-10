function Set-KeldorSecretToOnePassword {
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
        [string]$Field = 'password',

        [Parameter()]
        [switch]$Force
    )

    $OnePasswordCommand = Get-Command -Name 'op' -ErrorAction SilentlyContinue
    if ($null -eq $OnePasswordCommand) {
        throw "The OnePassword CLI command 'op' is not installed."
    }

    throw "Writing secrets with the OnePassword provider is not supported until a safe op CLI input method is available. Specify -Provider SecretManagement or -Provider Environment."
}
