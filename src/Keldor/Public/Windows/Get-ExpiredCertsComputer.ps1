function Get-ExpiredCertsComputer {
<#
.SYNOPSIS
    Gets Expired Certs Computer.

.DESCRIPTION
    Gets Expired Certs Computer.

.EXAMPLE
    Get-ExpiredCertsComputer
    Runs Get-ExpiredCertsComputer.

.OUTPUTS
    System.Object

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 10/04/2018 20:46:38
    LASTEDIT: 10/04/2018 21:08:31

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-ExpiredCertsComputer
#>





        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-ExpiredCertsComputer')]
    Param ()
$cd = Get-Date
    $certs = Get-ChildItem -Path Cert:\LocalMachine -Recurse | Select-Object *

    $excerts = $null
    $excerts = @()

    foreach ($cer in $certs) {
        if ($null -ne $cer.NotAfter -and $cer.NotAfter -lt $cd) {
            $excerts += ($cer | Where-Object {$_.PSParentPath -notlike "*Root"} | Select-Object FriendlyName,SubjectName,NotBefore,NotAfter,SerialNumber,EnhancedKeyUsageList,DnsNameList,Issuer,Thumbprint,PSParentPath)
        }
    }
}
