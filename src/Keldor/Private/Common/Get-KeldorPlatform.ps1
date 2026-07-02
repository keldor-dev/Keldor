function Get-KeldorPlatform {
    [CmdletBinding()]
    param()

    $isWindowsVariable = Get-Variable -Name IsWindows -ErrorAction SilentlyContinue
    $isMacOSVariable = Get-Variable -Name IsMacOS -ErrorAction SilentlyContinue
    $isLinuxVariable = Get-Variable -Name IsLinux -ErrorAction SilentlyContinue

    if ($null -ne $isWindowsVariable -and $null -ne $isMacOSVariable -and $null -ne $isLinuxVariable) {
        if ($isWindowsVariable.Value) { return 'Windows' }
        if ($isMacOSVariable.Value) { return 'macOS' }
        if ($isLinuxVariable.Value) { return 'Linux' }
    }

    if ($PSVersionTable.PSEdition -eq 'Desktop') {
        return 'Windows'
    }

    try {
        $osDescription = [System.Runtime.InteropServices.RuntimeInformation]::OSDescription
        if ($osDescription -match 'Windows') { return 'Windows' }
        if ($osDescription -match 'Darwin|macOS|Mac OS') { return 'macOS' }
        if ($osDescription -match 'Linux') { return 'Linux' }
    }
    catch {
        return 'Unknown'
    }

    return 'Unknown'
}
