function Convert-IPtoINT64 () {
    <#
.SYNOPSIS
    Converts IP to INT64.

.DESCRIPTION
    Converts IP to INT64.

.PARAMETER IPAddress
    Specifies the IP address value.

.EXAMPLE
    Convert-IPtoINT64 -IPAddress 192.168.1.1
    Runs Convert-IPtoINT64.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Convert-IPtoINT64
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Convert-IPtoINT64')]
    param (
        [Alias('IP', 'IPs', 'IPv4', 'Address')]
        $IPAddress
    )
    $octets = $IPAddress.split(".")
    return [int64]([int64]$octets[0] * 16777216 + [int64]$octets[1] * 65536 + [int64]$octets[2] * 256 + [int64]$octets[3])
}
