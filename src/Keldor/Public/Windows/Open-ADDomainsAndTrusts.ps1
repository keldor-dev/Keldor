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

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 08/19/2017 22:27:24
    LASTEDIT: 2022-09-04 12:04:10
    KEYWORDS:

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
