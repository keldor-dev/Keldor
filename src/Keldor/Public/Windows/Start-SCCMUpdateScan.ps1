function Start-SCCMUpdateScan {
    <#
.SYNOPSIS
    Starts a Configuration Manager software-update scan.

.DESCRIPTION
    Reads the last Configuration Manager update scan time and triggers the update scan and evaluation schedules
    when the last scan was at least ten minutes ago.

.PARAMETER ComputerName
    Specifies the name of one or more computers.

.EXAMPLE
    Start-SCCMUpdateScan

    Starts an update scan on the local Configuration Manager client when eligible.

.EXAMPLE
    Start-SCCMUpdateScan -ComputerName 'SERVER01'

    Starts an eligible update scan on SERVER01 through PowerShell remoting.

.OUTPUTS
    System.Management.Automation.PSCustomObject

.LINK
    https://docs.keldor.dev/powershell/keldor/Start-SCCMUpdateScan
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Start-SCCMUpdateScan')]
    [Alias()]
    param(
        [Parameter(
            #HelpMessage = "Enter one or more computer names separated by commas.",
            Mandatory = $false#,
            #Position=0,
            #ValueFromPipeline = $true
        )]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    process {
        foreach ($Comp in $ComputerName) {
            if ($Comp -eq $env:COMPUTERNAME) {
                Get-WmiObject -Query "SELECT * FROM CCM_UpdateStatus" -Namespace "root\ccm\SoftwareUpdates\UpdatesStore" | ForEach-Object {
                    if ($_.ScanTime -gt $ScanTime) { $ScanTime = $_.ScanTime }
                }; $LastScan = ([System.Management.ManagementDateTimeConverter]::ToDateTime($ScanTime)); $LastScan;
                if (((Get-Date) - $LastScan).minutes -ge 10 -and $PSCmdlet.ShouldProcess($Comp, "Start SCCM update scan")) {
                    [void]([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000113}');
                    ([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000108}'); "Update scan and evaluation"
                }
            } else {
                if ($PSCmdlet.ShouldProcess($Comp, "Start SCCM update scan")) {
                    Invoke-Command -ComputerName $Comp -ScriptBlock { #DevSkim: ignore DS104456
                        Get-WmiObject -Query "SELECT * FROM CCM_UpdateStatus" -Namespace "root\ccm\SoftwareUpdates\UpdatesStore" | ForEach-Object {
                            if ($_.ScanTime -gt $ScanTime) { $ScanTime = $_.ScanTime }
                        }; $LastScan = ([System.Management.ManagementDateTimeConverter]::ToDateTime($ScanTime)); $LastScan;
                        if (((Get-Date) - $LastScan).minutes -ge 10) {
                            [void]([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000113}');
                            ([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000108}'); "Update scan and evaluation"
                        }
                    }
                }
            }#not local
        }#foreach comp
    }
}
