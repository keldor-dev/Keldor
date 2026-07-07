function Restore-WindowsUpdate {
<#
.SYNOPSIS
    Restores Windows Update.

.DESCRIPTION
    Restores Windows Update.

.EXAMPLE
    Restore-WindowsUpdate
    Runs Restore-WindowsUpdate.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Restore-WindowsUpdate
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Restore-WindowsUpdate')]
    Param ()
    if (Test-KeldorAdministrator) {dism.exe /Online /Cleanup-image /Restorehealth}
    else {Write-Error "Must be ran as admin"}
}
