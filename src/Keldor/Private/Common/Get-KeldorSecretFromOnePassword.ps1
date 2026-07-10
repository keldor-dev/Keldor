function Get-KeldorSecretFromOnePassword {
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
        return $null
    }

    if ([string]::IsNullOrWhiteSpace($Vault)) {
        $SecretReference = "op://$Name/password"
    } else {
        $SecretReference = "op://$Vault/$Name/password"
    }

    try {
        $SecretValue = & op read $SecretReference 2>$null
        if ($OnePasswordCommand.CommandType -eq 'Application' -and $LASTEXITCODE -ne 0) {
            return $null
        }

        if ($null -eq $SecretValue) {
            return $null
        }

        return ([string]::Join([Environment]::NewLine, @($SecretValue))).TrimEnd("`r", "`n")
    } catch {
        return $null
    }
}
