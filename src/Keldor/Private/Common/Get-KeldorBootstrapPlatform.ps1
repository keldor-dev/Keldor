function Get-KeldorBootstrapPlatform {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    if ($PSVersionTable.PSEdition -eq 'Desktop') {
        return 'Windows'
    }

    if ($IsWindows) {
        return 'Windows'
    }

    if ($IsMacOS) {
        return 'macOS'
    }

    if ($IsLinux) {
        return 'Linux'
    }

    return 'Unknown'
}
