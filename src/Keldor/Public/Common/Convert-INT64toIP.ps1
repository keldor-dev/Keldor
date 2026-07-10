function Convert-INT64toIP() {
    <#
.SYNOPSIS
    Converts INT64 to IP.

.DESCRIPTION
    Converts INT64 to IP.

.PARAMETER int
    Specifies the int value.

.EXAMPLE
    Convert-INT64toIP
    Runs Convert-INT64toIP.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Convert-INT64toIP
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Convert-INT64toIP')]
    param ([int64]$int)
    return (([math]::truncate($int / 16777216)).tostring() + "." + ([math]::truncate(($int % 16777216) / 65536)).tostring() + "." + ([math]::truncate(($int % 65536) / 256)).tostring() + "." + ([math]::truncate($int % 256)).tostring())
}
