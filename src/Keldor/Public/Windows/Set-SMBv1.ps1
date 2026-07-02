#need to finish https://support.microsoft.com/en-us/help/2696547/how-to-detect-enable-and-disable-smbv1-smbv2-and-smbv3-in-windows-and
function Set-SMBv1 {
<#
.SYNOPSIS
    Sets SM Bv1.

.DESCRIPTION
    Sets SM Bv1.

.PARAMETER On
    Specifies whether to enable the On option.

.EXAMPLE
    Set-SMBv1
    Runs Set-SMBv1.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 01/31/2018 09:32:17
    LASTEDIT: 02/09/2018 00:47:46
    KEYWORDS:
    REQUIRES:
    -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-SMBv1
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-SMBv1')]
    Param (
        [Parameter()]
        [Switch]$On
    )

    #Determine OS
    $os = (Get-OperatingSystem).OS

    if ($On) {
        if ($os -match "2008" -or $os -match "7") {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" SMB1 -Type DWORD -Value 1 –Force
        }
        else {
            Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
        }
    }
    else {
        if ($os -match "2008" -or $os -match "7") {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" SMB1 -Type DWORD -Value 0 –Force
        }
        else {
            Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
        }
    }
}
