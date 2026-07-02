function Set-StoreLookup {
<#
.SYNOPSIS
    Sets Store Lookup.

.DESCRIPTION
    Sets Store Lookup.

.PARAMETER Yes
    Specifies whether to enable the Yes option.

.PARAMETER No
    Specifies whether to enable the No option.

.EXAMPLE
    Set-StoreLookup
    Runs Set-StoreLookup.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 02/08/2018 21:44:31
    LASTEDIT: 02/08/2018 21:44:31
    KEYWORDS:
    REQUIRES:
    #Requires -Version 3.0
    #Requires -Modules ActiveDirectory
    #Requires -PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
    #Requires -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-StoreLookup
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-StoreLookup')]
    Param (
        [Switch]$Yes,
        [Switch]$No
    )

    if ($Yes) {Set-ItemProperty -Path HKCU:\Software\Policies\Microsoft\Windows\Explorer -Name NoUseStoreOpenWith -Type DWord -Value 0 -Force}
    elseif ($No) {Set-ItemProperty -Path HKCU:\Software\Policies\Microsoft\Windows\Explorer -Name NoUseStoreOpenWith -Type DWord -Value 1 -Force}
    else {Set-ItemProperty -Path HKCU:\Software\Policies\Microsoft\Windows\Explorer -Name NoUseStoreOpenWith -Type DWord -Value 1 -Force}
}
