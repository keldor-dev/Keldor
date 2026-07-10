function Get-SCCMInstallStatus {
    <#
.SYNOPSIS
    Short description

.DESCRIPTION
    Long description

.PARAMETER ComputerName
    Specifies the name of one or more computers.

.EXAMPLE
    Get-SCCMInstallStatus
    Example of how to use this cmdlet

.EXAMPLE
    Get-SCCMInstallStatus -PARAMETER
    Another example of how to use this cmdlet but with a parameter or switch.

.OUTPUTS
    System.Management.Automation.PSCustomObject

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-SCCMInstallStatus
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-SCCMInstallStatus')]
    [Alias()]
    param(
        [Parameter(
            #HelpMessage = "Enter one or more computer names separated by commas.",
            Mandatory = $false#,
            #Position=0,
            #ValueFromPipeline = $true
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Info', 'Error', 'Warning', 'One', 'Two', 'Three')]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    $status = Invoke-Command -ComputerName $ComputerName -ScriptBlock { #DevSkim: ignore DS104456
        try {
            $CCMUpdate = get-wmiobject -query "SELECT * FROM CCM_SoftwareUpdate" -namespace "ROOT\ccm\ClientSDK" -ErrorAction stop
            if (@($CCMUpdate | Where-Object { $_.EvaluationState -eq 2 -or $_.EvaluationState -eq 3 -or $_.EvaluationState -eq 4 -or $_.EvaluationState -eq 5 -or $_.EvaluationState -eq 6 -or $_.EvaluationState -eq 7 -or $_.EvaluationState -eq 11 }).length -ne 0) {
                [pscustomobject]@{Computer = $env:computername; UpdateStatus = "3 - In Progress" }
            } elseif (@($CCMUpdate | Where-Object { $_.EvaluationState -eq 13 }).length -ne 0) {
                [pscustomobject]@{Computer = $env:computername; UpdateStatus = "4 - Update Failed" }
            } elseif (@($CCMUpdate | Where-Object { $_.EvaluationState -eq 8 -or $_.EvaluationState -eq 9 -or $_.EvaluationState -eq 10 }).length -ne 0) {
                [pscustomobject]@{Computer = $env:computername; UpdateStatus = "2 - Requires Reboot" }
            } elseif (@($CCMUpdate | Where-Object { $_.EvaluationState -eq 0 -or $_.EvaluationState -eq 1 }).length -ne 0) {
                [pscustomobject]@{Computer = $env:computername; UpdateStatus = "0 - Updates Available" }
            } else {
                [pscustomobject]@{Computer = $env:computername; UpdateStatus = "1 - Completed" }
            }
        } catch {
            [pscustomobject]@{Computer = $env:computername; UpdateStatus = "5 - Error Reading Update History" }
        }
    } -ErrorAction SilentlyContinue
    foreach ($server in $servers) {
        if ($status.computer -notcontains $server) {
            $status += [pscustomobject]@{Computer = $server; UpdateStatus = "6 - Remote Connection Failure" }
        }
    }
    $status | Select-Object Computer, UpdateStatus | Sort-Object -Property UpdateStatus, Computer
}
