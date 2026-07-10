function Remove-KeldorSecretFromOnePassword {
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

    $OnePasswordCommand = Get-Command -Name 'op' -ErrorAction SilentlyContinue
    if ($null -eq $OnePasswordCommand) {
        throw "The OnePassword CLI command 'op' is not installed."
    }

    if (-not [string]::IsNullOrWhiteSpace($Field)) {
        throw "Removing individual OnePassword fields is not supported by the current provider implementation."
    }

    if (-not (Test-KeldorSecretInOnePassword -Name $Name -Vault $Vault)) {
        throw "Secret '$Name' was not found in the OnePassword provider."
    }

    $Arguments = @('item', 'delete', $Name)
    if (-not [string]::IsNullOrWhiteSpace($Vault)) {
        $Arguments += @('--vault', $Vault)
    }

    try {
        & op @Arguments 2>$null | Out-Null
        if ($OnePasswordCommand.CommandType -eq 'Application' -and $LASTEXITCODE -ne 0) {
            throw "Unable to remove secret '$Name' using the OnePassword provider."
        }
    }
    catch {
        throw "Unable to remove secret '$Name' using the OnePassword provider."
    }

    'Removed'
}
