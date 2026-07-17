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

    $isSupported = $false
    if ($null -ne $parsedVersion) {
        switch ($detectedEdition) {
            'Desktop' {
                $isSupported = $parsedVersion.Major -eq 5 -and $parsedVersion.Minor -eq 1
            }
            'Core' {
                $isSupported = $parsedVersion.Major -eq 7 -and $parsedVersion.Minor -ge 4
            }
        }
    }

    if ($isSupported) {
        return $true
    }

    $message = "Keldor requires Windows PowerShell 5.1 or a Microsoft-supported PowerShell 7 release " +
    "beginning with PowerShell 7.4. Detected PowerShell edition '$detectedEdition' version " +
    "'$detectedVersion'. Obsolete PowerShell releases are intentionally unsupported. See " +
    'https://docs.keldor.dev/powershell/keldor/compatibility.'
    $exception = New-Object System.PlatformNotSupportedException $message
    $errorRecord = New-Object System.Management.Automation.ErrorRecord(
        $exception,
        'Keldor.UnsupportedPowerShellRuntime',
        [System.Management.Automation.ErrorCategory]::NotImplemented,
        $Version
    )
    $PSCmdlet.ThrowTerminatingError($errorRecord)
}
