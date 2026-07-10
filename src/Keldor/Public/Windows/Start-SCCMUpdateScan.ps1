function Start-SCCMUpdateScan {
    <#
.SYNOPSIS
    Short description

.DESCRIPTION
    Long description

.PARAMETER ComputerName
    Specifies the name of one or more computers.

.EXAMPLE
    Start-SCCMUpdateScan
    Example of how to use this cmdlet

.EXAMPLE
    Start-SCCMUpdateScan -PARAMETER
    Another example of how to use this cmdlet but with a parameter or switch.

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
