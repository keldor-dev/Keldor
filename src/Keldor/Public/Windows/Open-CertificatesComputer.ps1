function Open-CertificatesComputer {
    <#
.SYNOPSIS
    Opens Certificates Computer.

.DESCRIPTION
    Opens Certificates Computer.

.EXAMPLE
    Open-CertificatesComputer
    Runs Open-CertificatesComputer.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-CertificatesComputer
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-CertificatesComputer')]
    param ()
    certlm.msc
}
