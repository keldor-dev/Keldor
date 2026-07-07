function Convert-IPtoINT64 () {
  <#
.SYNOPSIS
    Converts IP to INT64.

.DESCRIPTION
    Converts IP to INT64.

.PARAMETER IP
    Specifies the IP value.

.EXAMPLE
    Convert-IPtoINT64
    Runs Convert-IPtoINT64.

.OUTPUTS
    System.Object

.NOTES
    Author: Skyler Hart

.LINK
    https://docs.keldor.dev/powershell/keldor/Convert-IPtoINT64
#>







  [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Convert-IPtoINT64')]
  param ($IP)
  $octets = $IP.split(".")
  return [int64]([int64]$octets[0] * 16777216 + [int64]$octets[1] * 65536 + [int64]$octets[2] * 256 + [int64]$octets[3])
}
