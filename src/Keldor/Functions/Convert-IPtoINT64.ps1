function Convert-IPtoINT64 () {
        <#
        .LINK
        https://docs.keldor.dev/powershell/keldor/Convert-IPtoINT64
        #>
        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Convert-IPtoINT64')]
param ($IP)
    $octets = $IP.split(".")
    return [int64]([int64]$octets[0]*16777216 +[int64]$octets[1]*65536 +[int64]$octets[2]*256 +[int64]$octets[3])
}
