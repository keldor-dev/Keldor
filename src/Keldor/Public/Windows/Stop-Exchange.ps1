function Stop-Exchange {
<#
.SYNOPSIS
    Stops Exchange.

.DESCRIPTION
    Stops Exchange.

.EXAMPLE
    Stop-Exchange
    Runs Stop-Exchange.

.OUTPUTS
    System.Object

.NOTES
    Author: Skyler Hart
    Created: 2020-10-24 11:00:45
    Last Edit: 2020-10-24 11:00:45
    Keywords:
    Requires:
    -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Stop-Exchange
#>





        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Stop-Exchange')]
    Param ()
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Get-Service -Name * | Where-Object {$_.DisplayName -match "Exchange"} | Stop-Service -Force
    }
    else {
        Write-Output "Must run PowerShell as admin to run Stop-Exchange."
    }
}
