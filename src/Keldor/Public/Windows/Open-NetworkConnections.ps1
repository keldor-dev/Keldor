function Open-NetworkConnections {
<#
.SYNOPSIS
    Opens Network Connections.

.DESCRIPTION
    Opens Network Connections.

.EXAMPLE
    Open-NetworkConnections
    Runs Open-NetworkConnections.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    LASTEDIT: 08/18/2017 20:49:17
    KEYWORDS:
    REQUIRES:
    #Requires -Version 3.0
    #Requires -Modules ActiveDirectory
    #Requires -PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
    #Requires -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-NetworkConnections
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-NetworkConnections')]
    [Alias('network','connections')]
    param()
    control.exe ncpa.cpl
}
