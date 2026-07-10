function Restart-DNS {
    <#
.SYNOPSIS
    Restarts DNS.

.DESCRIPTION
    Restarts DNS.

.PARAMETER DC
    Specifies the DC value.

.PARAMETER All
    Specifies whether to enable the All option.

.EXAMPLE
    Restart-DNS
    Runs Restart-DNS.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Restart-DNS
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Restart-DNS')]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [Alias('Host', 'Name', 'Computer', 'CN', 'ComputerName')]
        [string]$DC = "$env:COMPUTERNAME",
        [Switch]$All
    )
    if (Get-Module -ListAvailable -Name ActiveDirectory) {
        if (!($All)) {
            Write-Output "Restarting DNS service on $DC"
            try {
                if ($PSCmdlet.ShouldProcess($DC, "Restart DNS service")) {
                    Restart-Service -inputobject $(Get-Service -ComputerName $DC -Name DNS) -Force
                }
            } catch { throw "Unable to connect to $DC or failed to restart service." }
        }#if not all
        elseif ($All) {
            $AllDCs = (Get-ADForest).Domains | ForEach-Object { Get-ADDomainController -Filter * -Server $_ }
            foreach ($Srv in $AllDCs) {
                $SrvName = $Srv.HostName
                Write-Output "Restarting DNS service on $SrvName"
                try {
                    if ($PSCmdlet.ShouldProcess($SrvName, "Restart DNS service")) {
                        Restart-Service -inputobject $(Get-Service -ComputerName $SrvName -Name DNS) -Force
                    }
                } catch { throw "Unable to connect to $DC or failed to restart service." }
            }#foreach dc
        }#elseif
    } else {
        Write-Warning "Active Directory module is not installed and is required to run this command."
    }
}
