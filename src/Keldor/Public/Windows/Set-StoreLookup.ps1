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

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-StoreLookup
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-StoreLookup')]
    Param (
        [Switch]$Yes,
        [Switch]$No
    )

    if ($Yes) {
        if ($PSCmdlet.ShouldProcess('HKCU:\Software\Policies\Microsoft\Windows\Explorer\NoUseStoreOpenWith', "Set to 0")) {
            Set-ItemProperty -Path HKCU:\Software\Policies\Microsoft\Windows\Explorer -Name NoUseStoreOpenWith -Type DWord -Value 0 -Force
        }
    }
    elseif ($No) {
        if ($PSCmdlet.ShouldProcess('HKCU:\Software\Policies\Microsoft\Windows\Explorer\NoUseStoreOpenWith', "Set to 1")) {
            Set-ItemProperty -Path HKCU:\Software\Policies\Microsoft\Windows\Explorer -Name NoUseStoreOpenWith -Type DWord -Value 1 -Force
        }
    }
    else {
        if ($PSCmdlet.ShouldProcess('HKCU:\Software\Policies\Microsoft\Windows\Explorer\NoUseStoreOpenWith', "Set to 1")) {
            Set-ItemProperty -Path HKCU:\Software\Policies\Microsoft\Windows\Explorer -Name NoUseStoreOpenWith -Type DWord -Value 1 -Force
        }
    }
}
