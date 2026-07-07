function Get-UpTime {
<#
.SYNOPSIS
    Gets Up Time.

.DESCRIPTION
    Gets Up Time.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Get-UpTime
    Runs Get-UpTime.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-UpTime
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-UpTime')]
    Param (
        [Parameter(
            Mandatory=$false,
            Position=0
        )]
        [Alias('Host','Name','Computer','CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    foreach ($Comp in $ComputerName) {
        try {
            $wmiq = Get-WmiObject Win32_OperatingSystem -ComputerName $Comp -erroraction stop
            $bootup = [Management.ManagementDateTimeConverter]::ToDateTime($wmiq.LastBootUpTime)
            $ts = New-TimeSpan $bootup
            $tot = [string]([math]::Round($ts.totalhours,2)) + " h"
            [PSCustomObject]@{
                ComputerName = $Comp
                LastBoot = $bootup
                Total = $tot
                Days = ($ts.Days)
                Hours = ($ts.Hours)
                Minutes = ($ts.Minutes)
                Seconds = ($ts.Seconds)
            }#newobject
        }#try
        catch {
            $bootup = "Failed: Could not connect to computer"
            [PSCustomObject]@{
                ComputerName = $Comp
                LastBoot = $bootup
                Total = ""
                Days = ""
                Hours = ""
                Minutes = ""
                Seconds = ""
            }#newobject
        }#catch
    }#foreach comp
}
