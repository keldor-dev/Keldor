function Get-KeldorSystemSnapshot {
    [CmdletBinding()]
    param()

    $platform = Get-KeldorPlatform

    try {
        switch ($platform) {
            'Windows' { return Get-KeldorWindowsSystemSnapshot }
            'Linux' { return Get-KeldorLinuxSystemSnapshot }
            'macOS' { return Get-KeldorMacOSSystemSnapshot }
            default {
                return New-KeldorSystemSnapshot `
                    -ComputerName ([Environment]::MachineName) `
                    -Platform $null `
                    -IsSuccessful $false `
                    -ErrorCategory 'NotImplemented' `
                    -ErrorCode 'Keldor.SystemInfo.PlatformUnknown' `
                    -ErrorMessage 'Keldor could not determine the current operating-system platform.'
            }
        }
    } catch {
        New-KeldorSystemSnapshot `
            -ComputerName ([Environment]::MachineName) `
            -Platform $(if ($platform -eq 'Unknown') { $null } else { $platform }) `
            -IsSuccessful $false `
            -ErrorCategory ([string]$_.CategoryInfo.Category) `
            -ErrorCode $_.FullyQualifiedErrorId `
            -ErrorMessage $_.Exception.Message
    }
}
