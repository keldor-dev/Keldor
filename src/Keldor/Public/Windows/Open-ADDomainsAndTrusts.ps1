function Open-ADDomainsAndTrusts {
<#
.SYNOPSIS
    Opens AD Domains And Trusts.

.DESCRIPTION
    Opens AD Domains And Trusts.

.EXAMPLE
    Open-ADDomainsAndTrusts
    Runs Open-ADDomainsAndTrusts.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-ADDomainsAndTrusts
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-ADDomainsAndTrusts')]
    [Alias('trusts')]
    param()
    try {
        $ErrorActionPreference = "Stop"
        domain.msc
    }
    catch {
        Write-Output "Active Directory snapins are not installed/enabled."
    }
}
