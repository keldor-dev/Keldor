function Test-KeldorSecretInOnePassword {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter()]
        [string]$Vault
    )

    $OnePasswordCommand = Get-Command -Name 'op' -ErrorAction SilentlyContinue
    if ($null -eq $OnePasswordCommand) {
        return $false
    }

    try {
        $Arguments = @('item', 'get', $Name, '--format', 'json')
        if (-not [string]::IsNullOrWhiteSpace($Vault)) {
            $Arguments += @('--vault', $Vault)
        }

        & op @Arguments 2>$null | Out-Null
        if ($OnePasswordCommand.CommandType -eq 'Application' -and $LASTEXITCODE -ne 0) {
            return $false
        }

        return $true
    }
    catch {
        return $false
    }
}
