function Get-ComputerADSite {
    <#
.SYNOPSIS
    Gets Computer AD Site.

.DESCRIPTION
    Gets Computer AD Site.

.PARAMETER ComputerName
    Specifies the computer or computers

.EXAMPLE
    Get-ComputerADSite
    Runs Get-ComputerADSite.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-ComputerADSite
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-ComputerADSite')]
    param (
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true
        )]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    begin {
        $info = @()
    }
    process {
        $info = foreach ($comp in $ComputerName) {
            $site = nltest /server:$comp /dsgetsite 2>$null
            if ($LASTEXITCODE -eq 0) { $st = $site[0] }
            else { $st = "NA" }
            [PSCustomObject]@{
                ComputerName = $comp
                SiteName     = $st
                Site         = $st
            }#new object
        }
    }
    end {
        $info
    }
}
