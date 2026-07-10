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

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-ExpiredCertsComputer
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-ExpiredCertsComputer')]
    param ()
    $cd = Get-Date
    $certs = Get-ChildItem -Path Cert:\LocalMachine -Recurse | Select-Object *

    $excerts = $null
    $excerts = @()

    foreach ($cer in $certs) {
        if ($null -ne $cer.NotAfter -and $cer.NotAfter -lt $cd) {
            $excerts += ($cer | Where-Object { $_.PSParentPath -notlike "*Root" } | Select-Object FriendlyName, SubjectName, NotBefore, NotAfter, SerialNumber, EnhancedKeyUsageList, DnsNameList, Issuer, Thumbprint, PSParentPath)
        }
    }
}
