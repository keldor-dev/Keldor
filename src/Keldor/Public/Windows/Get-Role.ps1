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

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 10/20/2017 16:30:43
    LASTEDIT: 10/20/2017 16:30:43
    KEYWORDS:

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-Role
#>





        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-Role')]
    Param ()
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {$Role = "Admin"}
    else {$Role = "Non-Admin"}
    $Role
}
