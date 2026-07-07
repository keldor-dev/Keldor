function Restart-ActiveDirectory {
<#
.SYNOPSIS
    Restarts Active Directory.

.DESCRIPTION
    Restarts Active Directory.

.PARAMETER DC
    Specifies the DC value.

.PARAMETER All
    Specifies whether to enable the All option.

.EXAMPLE
    Restart-ActiveDirectory
    Runs Restart-ActiveDirectory.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Restart-ActiveDirectory
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Restart-ActiveDirectory')]
    Param (
        [Parameter(Mandatory=$false, Position=0)]
        [Alias('Host','Name','Computer','CN','ComputerName')]
        [string]$DC = "$env:COMPUTERNAME",
        [Switch]$All
    )
    if (Get-Module -ListAvailable -Name ActiveDirectory) {
        if (!($All)) {
            Write-Information "Restarting Active Directory service on $DC"
            try {
                if ($PSCmdlet.ShouldProcess($DC, "Restart Active Directory service")) {
                    Restart-Service -inputobject $(Get-Service -ComputerName $DC -Name NTDS -ErrorAction Stop) -Force -ErrorAction Stop
                }
            }
            catch {Throw "Unable to connect to $DC or failed to restart service."}
        }#if not all
        elseif ($All) {
            $AllDCs = (Get-ADForest).Domains | ForEach-Object {Get-ADDomainController -Filter * -Server $_}
            foreach ($Srv in $AllDCs) {
                $SrvName = $Srv.HostName
                Write-Output "Restarting Active Directory service on $SrvName"
                try {
                    if ($PSCmdlet.ShouldProcess($SrvName, "Restart Active Directory service")) {
                        Restart-Service -inputobject $(Get-Service -ComputerName $SrvName -Name NTDS) -Force
                    }
                }
                catch {Throw "Unable to connect to $DC or failed to restart service."}
            }#foreach dc
        }#elseif
    }
    else {
        Write-Warning "Active Directory module is not installed and is required to run this command."
    }
}
