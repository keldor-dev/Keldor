function Open-DNSmgmt {
<#
.SYNOPSIS
    Opens DN Smgmt.

.DESCRIPTION
    Opens DN Smgmt.

.EXAMPLE
    Open-DNSmgmt
    Runs Open-DNSmgmt.

.OUTPUTS
    System.Object

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 08/19/2017 22:26:23
    LASTEDIT: 2022-09-04 12:10:54
    KEYWORDS:

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-DNSmgmt
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-DNSmgmt')]
    [Alias('dns')]
    param()
    try {
        $ErrorActionPreference = "Stop"
        dnsmgmt.msc
    }
    catch {
        Write-Output "Active Directory snapins are not installed/enabled."
    }
}
