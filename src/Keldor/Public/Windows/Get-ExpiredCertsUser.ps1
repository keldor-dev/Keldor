function Get-ExpiredCertsUser {
<#
.SYNOPSIS
    Gets Expired Certs User.

.DESCRIPTION
    Gets Expired Certs User.

.EXAMPLE
    Get-ExpiredCertsUser
    Runs Get-ExpiredCertsUser.

.OUTPUTS
    System.Object

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 10/04/2018 21:08:39
    LASTEDIT: 10/04/2018 21:09:34

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-ExpiredCertsUser
#>





        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-ExpiredCertsUser')]
    Param ()
$cd = Get-Date
    $certs = Get-ChildItem -Path Cert:\CurrentUser -Recurse | Select-Object *

    $excerts = $null
    $excerts = @()

    foreach ($cer in $certs) {
        if ($null -ne $cer.NotAfter -and $cer.NotAfter -lt $cd) {
            $excerts += ($cer | Where-Object {$_.PSParentPath -notlike "*Root"} | Select-Object FriendlyName,SubjectName,NotBefore,NotAfter,SerialNumber,EnhancedKeyUsageList,DnsNameList,Issuer,Thumbprint,PSParentPath)
        }
    }
}
