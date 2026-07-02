function Open-ConfigurationManager {
<#
.SYNOPSIS
    Opens Configuration Manager.

.DESCRIPTION
    Opens Configuration Manager.

.EXAMPLE
    Open-ConfigurationManager
    Runs Open-ConfigurationManager.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    CREATED: Sometime before 2017-08-07
    LASTEDIT: 2020-09-28 09:31:24
    KEYWORDS:
    REQUIRES:
    #Requires -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-ConfigurationManager
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-ConfigurationManager')]
    [Alias('configmgr')]
    param()
    if (Test-Path "C:\Windows\CCM\SMSCFGRC.cpl") {Start-Process C:\Windows\CCM\SMSCFGRC.cpl}
    elseif (Test-Path "C:\Windows\SysWOW64\CCM\SMSCFGRC.cpl") {Start-Process C:\Windows\SysWOW64\CCM\SMSCFGRC.cpl}
    elseif (Test-Path "C:\Windows\System32\CCM\SMSCFGRC.cpl") {Start-Process C:\Windows\System32\CCM\SMSCFGRC.cpl}
    else {Throw "Configuration Manager not found"}
}
