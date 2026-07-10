function Get-FeaturesOnDemand {
    <#
.SYNOPSIS
    Gets Features On Demand.

.DESCRIPTION
    Gets Features On Demand.

.EXAMPLE
    Get-FeaturesOnDemand
    Runs Get-FeaturesOnDemand.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-FeaturesOnDemand
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-FeaturesOnDemand')]
    param ()

    if (Test-KeldorAdministrator) {
        $info = (dism /online /get-capabilities | Where-Object { $_ -like "Capability Identity*" -or $_ -like "State*" })
        $idents = ($info | Where-Object { $_ -like "Capa*" }).Split(' : ') | Where-Object { $_ -ne "Capability" -and $_ -ne "Identity" -and $_ -ne $null -and $_ -ne "" }
        $state = $info | Where-Object { $_ -like "State*" }
        $state = $state -replace "State : "

        foreach ($ident in $idents) {
            $state2 = $state[$i]
            [PSCustomObject]@{
                CapabilityIdentity = $ident
                State              = $state2
            }
        }
    }#if admin
    else {
        Write-Error "Not admin. Please run PowerShell as admin."
    }
}
