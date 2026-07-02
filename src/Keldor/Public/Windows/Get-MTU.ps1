function Get-MTU {
<#
.SYNOPSIS
    Gets MTU.

.DESCRIPTION
    Gets MTU.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Get-MTU
    Runs Get-MTU.

.OUTPUTS
    System.Object

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 09/21/2017 13:06:23
    LASTEDIT: 2020-05-23 17:39:06
    KEYWORDS:

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-MTU
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-MTU')]
    Param (
        [Parameter(
            Mandatory=$false,
            Position=0
        )]
        [Alias('Host','Name','Computer','CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    foreach ($comp in $ComputerName) {
        $netad = (Get-WmiObject Win32_NetworkAdapter -ComputerName $comp -Filter NetConnectionStatus=2  -ErrorAction Stop | Select-Object * | Where-Object {$null -ne $_.MACAddress -or $_.MACAddress -ne ""})
        $RegBase = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$comp)
        $RegLoc = 'SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces'

        $RegKey = $RegBase.OpenSubKey($RegLoc)
        $ints = $RegKey.GetSubKeyNames()
        foreach ($int in $ints) {
            if ($netad -match $int) {
                #$HashProp = @()
                $RegLoc2 = $RegLoc + "\" + $int
                $RegKey2 = $RegBase.OpenSubKey($RegLoc2)
                $mtu = $null
                $mtu = $RegKey2.GetValue('MTU')
                if ([string]::IsNullOrWhiteSpace($mtu)) {
                    $mtu = "1500"
                }
                $domain = $RegKey2.GetValue('Domain')
                $dhcpaddr = $RegKey2.GetValue('DhcpIPAddress')
                $ipaddr = $RegKey2.GetValue('IPAddress')
                $ip = $null
                if ([string]::IsNullOrWhiteSpace($dhcpaddr)) {
                    $ip = $ipaddr[0]
                }
                else {
                    $ip = $dhcpaddr
                }

                if ([string]::IsNullOrWhiteSpace($ip) -or $ip -like "0*") {
                    #don't report
                }
                else {
                    $adprop = $netad | Where-Object {$_.GUID -eq $int}
                    [PSCustomObject]@{
                        ComputerName = $comp
                        Name = ($adprop.Name)
                        ConnectionID = ($adprop.NetConnectionID)
                        MTU = $mtu
                        Index = ($adprop.DeviceID)
                        IP = $ip
                        Domain = $domain
                    }#new object
                }
            }
        }
    }#foreach computer
}
