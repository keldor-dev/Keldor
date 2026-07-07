function Stop-Database {
<#
.SYNOPSIS
    Stops Database.

.DESCRIPTION
    Stops Database.

.EXAMPLE
    Stop-Database
    Runs Stop-Database.

.OUTPUTS
    System.Object

.NOTES
    Author: Skyler Hart
    Created: 2020-10-24 19:01:26
    Last Edit: 2023-02-07 22:33:18
    Keywords:
    Requires:
    -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Stop-Database
#>





    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Stop-Database')]
    [Alias('Stop-Oracle','Stop-SQL','Stop-MongoDB')]
    param()
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Get-Service -Name * | Where-Object {$_.DisplayName -match "Oracle" -or $_.DisplayName -match "SQL" -or $_.DisplayName -match "MongoDB"} | ForEach-Object {
            if ($PSCmdlet.ShouldProcess($_.Name, "Stop service")) {
                $_ | Stop-Service -Force
            }
        }
    }
    else {
        Write-Output "Must run PowerShell as admin to run Stop-Database."
    }
}
