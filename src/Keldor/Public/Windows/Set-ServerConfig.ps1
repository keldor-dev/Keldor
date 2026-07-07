function Set-ServerConfig {
<#
.SYNOPSIS
    Sets Server Config.

.DESCRIPTION
    Sets Server Config.

.EXAMPLE
    Set-ServerConfig
    Runs Set-ServerConfig.

.OUTPUTS
    System.Object

.NOTES
    Author: Skyler Hart
    Created: 2020-10-24 20:09:27
    Last Edit: 2020-10-24 20:09:27
    Keywords:
    Requires:
    -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-ServerConfig
#>





        [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-ServerConfig')]
    Param ()
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    $sc = $Global:KeldorConfig

    $netadapter = Get-NetAdapter
    foreach ($na in $netadapter) {
        $ia = $na.Name

        #DHCP
        if ($sc.SCDHCP -eq $true) {
            if ($PSCmdlet.ShouldProcess($ia, "Enable DHCP")) {
                $na | Set-NetIPInterface -Dhcp Enabled
            }
        }
        else {
            if ($PSCmdlet.ShouldProcess($ia, "Disable DHCP")) {
                $na | Set-NetIPInterface -Dhcp Disabled
            }
        }

        #IPv6
        if ($sc.SCIPv6 -eq $true) {
            if ($PSCmdlet.ShouldProcess($ia, "Enable IPv6 binding")) {
                Enable-NetAdapterBinding -InterfaceAlias $ia -ComponentID ms_tcpip6
            }
        }
        else {
            if ($PSCmdlet.ShouldProcess($ia, "Disable IPv6 binding")) {
                Disable-NetAdapterBinding -InterfaceAlias $ia -ComponentID ms_tcpip6
            }
        }

        #Link-Layer Topology Discovery Responder
        if ($sc.SCllrspndr -eq $true) {
            if ($PSCmdlet.ShouldProcess($ia, "Enable Link-Layer Topology Discovery Responder")) {
                Enable-NetAdapterBinding -InterfaceAlias $ia -ComponentID ms_rspndr
            }
        }
        else {
            if ($PSCmdlet.ShouldProcess($ia, "Disable Link-Layer Topology Discovery Responder")) {
                Disable-NetAdapterBinding -InterfaceAlias $ia -ComponentID ms_rspndr
            }
        }

        #Link-Layer Topology Discovery Mapper I/O
        if ($sc.SClltdio -eq $true) {
            if ($PSCmdlet.ShouldProcess($ia, "Enable Link-Layer Topology Discovery Mapper I/O")) {
                Enable-NetAdapterBinding -InterfaceAlias $ia -ComponentID ms_lltdio
            }
        }
        else {
            if ($PSCmdlet.ShouldProcess($ia, "Disable Link-Layer Topology Discovery Mapper I/O")) {
                Disable-NetAdapterBinding -InterfaceAlias $ia -ComponentID ms_lltdio
            }
        }

        #Offloading
        if ($sc.SCOffload -eq $true) {
            if ($PSCmdlet.ShouldProcess($ia, "Enable offloading")) {
                Set-NetAdapterAdvancedProperty -Name $ia -DisplayName "*Offloa*" -DisplayValue "Enabled"
            }
        }
        else {
            if ($PSCmdlet.ShouldProcess($ia, "Disable offloading")) {
                Set-NetAdapterAdvancedProperty -Name $ia -DisplayName "*Offloa*" -DisplayValue "Disabled"
            }
        }
    }#foreach network adapter

    #NetBIOS
    $NICS = Get-WmiObject Win32_NetworkAdapterConfiguration
    $nb = $sc.SCNetBios
    foreach ($NIC in $NICS) {
        if ($PSCmdlet.ShouldProcess($NIC.Description, "Set TCP/IP NetBIOS")) {
            $NIC.settcpipnetbios($nb)
        }
    }

    #RDP
    if ($PSCmdlet.ShouldProcess('HKLM:\System\CurrentControlSet\Control\Terminal Server', "Set fDenyTSConnections")) {
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value ($sc.SCRDP)
    }

    #Server Manager
    if ($sc.SCServerMgr -eq $true) {
        if ($PSCmdlet.ShouldProcess('ServerManager', "Enable scheduled task")) {
            Get-ScheduledTask -TaskName ServerManager | Enable-ScheduledTask
        }
    }
    else {
        if ($PSCmdlet.ShouldProcess('ServerManager', "Disable scheduled task")) {
            Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask
        }
    }

    #WINS
    $wdns = $sc.SCWDNS
    $lmh = $sc.SCLMHost
    $nicClass = Get-WmiObject -list Win32_NetworkAdapterConfiguration
    if ($PSCmdlet.ShouldProcess('Win32_NetworkAdapterConfiguration', "Set WINS configuration")) {
        $nicClass.enablewins($wdns,$lmh)
    }
}
