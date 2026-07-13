function Get-KeldorRuntimeInformationPlatform {
    [CmdletBinding()]
    param(
        [string]$OSDescription
    )

    if (!$PSBoundParameters.ContainsKey('OSDescription')) {
        try {
            $OSDescription = [System.Runtime.InteropServices.RuntimeInformation]::OSDescription
        } catch {
            return $null
        }
    }

    if ($OSDescription -match 'Windows') { return 'Windows' }
    if ($OSDescription -match 'Darwin|macOS|Mac OS') { return 'macOS' }
    if ($OSDescription -match 'Linux') { return 'Linux' }

    return $null
}

function Get-KeldorLegacyWindowsPlatform {
    [CmdletBinding()]
    param()

    try {
        $windowsPlatformIds = @('Win32S', 'Win32Windows', 'Win32NT', 'WinCE')
        if ($windowsPlatformIds -contains [Environment]::OSVersion.Platform.ToString()) {
            return 'Windows'
        }
    } catch {
        # Continue to the non-terminating WMI fallback.
    }

    try {
        if (Get-Command -Name Get-WmiObject -ErrorAction SilentlyContinue) {
            $operatingSystem = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction SilentlyContinue
            if ($null -ne $operatingSystem) {
                return 'Windows'
            }
        }
    } catch {
        # Platform detection must not prevent the module from loading.
    }

    return $null
}

function Get-KeldorPlatform {
    <#
    .SYNOPSIS
    Gets the current operating-system platform.

    .DESCRIPTION
    Identifies the operating-system family and returns exactly Windows, macOS, Linux, or Unknown.

    Get-KeldorPlatform identifies only the operating-system family. It does not return the operating-system edition,
    distribution, architecture, build, or version.

    .EXAMPLE
    Get-KeldorPlatform

    Returns the operating-system family for the current PowerShell session.

    .EXAMPLE
    if ((Get-KeldorPlatform) -eq 'Windows') {
        Write-Host 'Running on Windows.'
    }

    Uses the fixed platform contract to run platform-specific logic.

    .OUTPUTS
    System.String

    .LINK
    https://docs.keldor.dev/powershell/keldor/Get-KeldorPlatform
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    $isWindowsVariable = Get-Variable -Name IsWindows -ErrorAction SilentlyContinue
    if ($null -ne $isWindowsVariable -and $isWindowsVariable.Value) {
        return 'Windows'
    }

    $isMacOSVariable = Get-Variable -Name IsMacOS -ErrorAction SilentlyContinue
    if ($null -ne $isMacOSVariable -and $isMacOSVariable.Value) {
        return 'macOS'
    }

    $isLinuxVariable = Get-Variable -Name IsLinux -ErrorAction SilentlyContinue
    if ($null -ne $isLinuxVariable -and $isLinuxVariable.Value) {
        return 'Linux'
    }

    if ($PSVersionTable.PSEdition -eq 'Desktop') {
        return 'Windows'
    }

    try {
        $runtimePlatform = Get-KeldorRuntimeInformationPlatform
    } catch {
        $runtimePlatform = $null
    }
    if ($null -ne $runtimePlatform) {
        return $runtimePlatform
    }

    $legacyPlatform = Get-KeldorLegacyWindowsPlatform
    if ($null -ne $legacyPlatform) {
        return $legacyPlatform
    }

    return 'Unknown'
}
