function Open-FirewallLog {
<#
.SYNOPSIS
    Opens Firewall Log.

.DESCRIPTION
    Opens Firewall Log.

.PARAMETER Domain
    Specifies whether to enable the Domain option.

.PARAMETER Private
    Specifies whether to enable the Private option.

.PARAMETER Public
    Specifies whether to enable the Public option.

.EXAMPLE
    Open-FirewallLog
    Runs Open-FirewallLog.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 09/11/2017 14:50:51
    LASTEDIT: 09/11/2017 14:50:51
    KEYWORDS:
    REQUIRES:
    #Requires -Version 3.0
    #Requires -Modules ActiveDirectory
    #Requires -PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
    #Requires -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-FirewallLog
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-FirewallLog')]
    Param (
        [Parameter()]
        [Switch]$Domain,

        [Parameter()]
        [Switch]$Private,

        [Parameter()]
        [Switch]$Public
    )

    if ($Private -eq $true) {notepad %systemroot%\system32\logfiles\firewall\domainfirewall.log}
    elseif ($Public -eq $true) {notepad %systemroot%\system32\logfiles\firewall\privatefirewall.log}
    elseif ($Domain -eq $true -or ($Private -eq $false -and $Public -eq $false)) {notepad %systemroot%\system32\logfiles\firewall\publicfirewall.log}
}
