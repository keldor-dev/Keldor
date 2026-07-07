function Get-CertificateInventory {
<#
.SYNOPSIS
    Gets Certificate Inventory.

.DESCRIPTION
    Gets Certificate Inventory.

.EXAMPLE
    Get-CertificateInventory
    Runs Get-CertificateInventory.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-CertificateInventory
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-CertificateInventory')]
    [Alias('Get-CertInv','Get-CertInfo')]
    param()

    $cpath = @('Cert:\LocalMachine\My','Cert:\LocalMachine\Remote Desktop')

    $os = (Get-WmiObject Win32_OperatingSystem).ProductType

    if ($os -eq 1) {$type = "Workstation"}
    elseif (($os -eq 2) -or ($os -eq 3)) {$type = "Server"}

    $certinfo = foreach ($cp in $cpath) {
        Get-ChildItem $cp | Select-Object *
    }

    $certs = foreach ($cert in $certinfo) {
        $cp = $cert.PSParentPath -replace "Microsoft.PowerShell.Security\\Certificate\:\:",""

        if (($cert.Subject) -eq ($cert.Issuer)) {$ss = $true}
        else {$ss = $false}

        $daystoexpire = (New-TimeSpan -Start (get-date) -End ($cert.NotAfter)).Days

        [PSCustomObject]@{
            ComputerName = ($env:computername)
            ProductType = $type
            Subject = ($cert.Subject)
            Issuer = ($cert.Issuer)
            Location = $cp
            SelfSigned = $ss
            ValidFrom = ($cert.NotBefore)
            ValidTo = ($cert.NotAfter)
            DaysToExpiration = $daystoexpire
            SerialNumber = ($cert.SerialNumber)
            Thumbprint = ($cert.Thumbprint)
        }# new object
    }
    $certs | Select-Object ComputerName,ProductType,Location,Subject,Issuer,SelfSigned,ValidFrom,ValidTo,DaysToExpiration,SerialNumber,Thumbprint | Sort-Object Subject
}
