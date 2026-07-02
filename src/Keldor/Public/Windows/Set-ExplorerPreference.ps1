function Set-ExplorerPreference {
<#
.SYNOPSIS
    Sets Explorer Preference.

.DESCRIPTION
    Sets Explorer Preference.

.PARAMETER ThisPC
    Specifies whether to enable the This PC option.

.PARAMETER QuickAccess
    Specifies whether to enable the Quick Access option.

.EXAMPLE
    Set-ExplorerPreference
    Runs Set-ExplorerPreference.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 02/08/2018 21:26:47
    LASTEDIT: 02/08/2018 21:26:47
    KEYWORDS:
    REQUIRES:
    #Requires -Version 3.0
    #Requires -Modules ActiveDirectory
    #Requires -PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
    #Requires -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-ExplorerPreference
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-ExplorerPreference')]
    Param (
        [Switch]$ThisPC,
        [Switch]$QuickAccess
    )

    if ($ThisPC) {Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Type DWord -Value 1 -Force}
    elseif ($QuickAccess) {Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Type DWord -Value 2 -Force}
    else {Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Type DWord -Value 1 -Force}
}
