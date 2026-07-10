function Get-Role {
    <#
.SYNOPSIS
    Gets Role.

.DESCRIPTION
    Gets Role.

.EXAMPLE
    Get-Role
    Runs Get-Role.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-Role
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-Role')]
    param ()
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $Role = "Admin" }
    else { $Role = "Non-Admin" }
    $Role
}
