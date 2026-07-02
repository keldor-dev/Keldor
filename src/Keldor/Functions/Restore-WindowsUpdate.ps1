function Restore-WindowsUpdate {
<#
.Notes
    AUTHOR: Skyler Hart
    CREATED: 2021-12-03 19:41:37
    LASTEDIT: 2021-12-03 19:41:37
    KEYWORDS:
    REQUIRES:
        -RunAsAdministrator
.Link
    https://docs.keldor.dev/powershell/keldor/Restore-WindowsUpdate
#>
        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Restore-WindowsUpdate')]
    Param ()
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {dism.exe /Online /Cleanup-image /Restorehealth}
    else {Write-Error "Must be ran as admin"}
}
