function Open-ADSitesAndServices {
<#
.SYNOPSIS
    Opens AD Sites And Services.

.DESCRIPTION
    Opens AD Sites And Services.

.EXAMPLE
    Open-ADSitesAndServices
    Runs Open-ADSitesAndServices.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-ADSitesAndServices
#>

        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-ADSitesAndServices')]
    Param ()
try {
        $ErrorActionPreference = "Stop"
        dssite.msc
    }
    catch {
        Write-Output "Active Directory snapins are not installed/enabled."
    }
}
