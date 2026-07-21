function Test-KeldorPowerShellRuntime {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object]$Version,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [object]$Edition
    )

    $detectedVersion = if ($null -eq $Version) { '<missing>' } else { [string]$Version }
    $detectedEdition = if ([string]::IsNullOrWhiteSpace([string]$Edition)) { '<missing>' } else { [string]$Edition }
    $parsedVersion = $null

    try {
        if ($Version -is [version]) {
            $parsedVersion = $Version
        } elseif (-not [version]::TryParse([string]$Version, [ref]$parsedVersion)) {
            $parsedVersion = $null
        }
    } catch {
        $parsedVersion = $null
    }

    if ($null -ne $parsedVersion) {
        if (
            $detectedEdition -eq 'Desktop' -and
            $parsedVersion.Major -eq 5 -and
            $parsedVersion.Minor -eq 1
        ) {
            return $true
        }

        if ($detectedEdition -eq 'Core' -and $parsedVersion.Major -eq 7) {
            if ($parsedVersion.Minor -ge 4) {
                return $true
            }

            if ($parsedVersion.Minor -ge 2) {
                $message = "Keldor is running on PowerShell $detectedVersion. PowerShell 7.2 and 7.3 are supported " +
                'on a best-effort basis for restricted enterprise and government environments. PowerShell 7.6 LTS ' +
                'is recommended. Some commands may require a newer runtime. See ' +
                'https://docs.keldor.dev/powershell/keldor/compatibility.'
                Write-Warning -Message $message
                return $true
            }
        }
    }

    $message = "Keldor requires Windows PowerShell 5.1 or PowerShell 7.2 or later. Detected PowerShell edition " +
    "'$detectedEdition' version '$detectedVersion'. PowerShell 7.2 and 7.3 receive best-effort compatibility only; " +
    'PowerShell 7.6 LTS is recommended. See https://docs.keldor.dev/powershell/keldor/compatibility.'
    $exception = New-Object System.PlatformNotSupportedException $message
    $errorRecord = New-Object System.Management.Automation.ErrorRecord(
        $exception,
        'Keldor.UnsupportedPowerShellRuntime',
        [System.Management.Automation.ErrorCategory]::NotImplemented,
        $Version
    )
    $PSCmdlet.ThrowTerminatingError($errorRecord)
}
