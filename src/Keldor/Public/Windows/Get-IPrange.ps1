function Get-IPrange {
<#
.SYNOPSIS
    Lists IPs within a range, subnet, or CIDR block.

.DESCRIPTION
    Lists IPs within a range, subnet, or CIDR block.

.PARAMETER IPAddress
    An IP from the subnet mask or CIDR block you want a range for.

.PARAMETER CIDR
    Specifies what CIDR block notation you want to list IPs from.

.PARAMETER Subnet
    The subnet mask you want a range for.

.PARAMETER Start
    Specifies a path to one or more locations.

.PARAMETER End
    The ending IP in a range.

.EXAMPLE
    Get-IPrange -IPAddress 192.168.0.3 -subnet 255.255.255.192
    Will show all IPs within the 192.168.0.0 space with a subnet mask of 255.255.255.192 (CIDR 26.)

.EXAMPLE
    Get-IPrange -PARAMETER
    Another example of how to use this cmdlet but with a parameter or switch.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-IPrange
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-IPrange')]
    Param (
        [Parameter(
            Mandatory=$false,
            Position=0
        )]
        [Alias('IP','IPs','IPv4','Address','IPv4Address')]
        [string]$IPAddress,

        [Parameter(
            Mandatory=$false
        )]
        [Alias('Notation','Block')]
        [string]$CIDR,

        [Parameter(
            Mandatory=$false
        )]
        [Alias('Mask')]
        [string]$Subnet,

        [Parameter(
            Mandatory=$false
        )]
        [string]$Start,

        [Parameter(
            Mandatory=$false
        )]
        [string]$End
    )


    if ($IPAddress) {$ipaddr = [Net.IPAddress]::Parse($IPAddress)}
    if ($CIDR) {$maskaddr = [Net.IPAddress]::Parse((Convert-INT64toIP -int ([convert]::ToInt64(("1"*$CIDR+"0"*(32-$CIDR)),2)))) }
    if ($Subnet) {$maskaddr = [Net.IPAddress]::Parse($Subnet)}
    if ($IPAddress) {$networkaddr = new-object net.ipaddress ($maskaddr.address -band $ipaddr.address)}
    if ($IPAddress) {$broadcastaddr = new-object net.ipaddress (([system.net.ipaddress]::parse("255.255.255.255").address -bxor $maskaddr.address -bor $networkaddr.address))}

    if ($IPAddress) {
        $startaddr = Convert-IPtoINT64 -IPAddress $networkaddr.ipaddresstostring
        $endaddr = Convert-IPtoINT64 -IPAddress $broadcastaddr.ipaddresstostring
    } else {
        $startaddr = Convert-IPtoINT64 -IPAddress $start
        $endaddr = Convert-IPtoINT64 -IPAddress $end
    }

    for ($i = $startaddr; $i -le $endaddr; $i++) {
        Convert-INT64toIP -int $i
    }
}
