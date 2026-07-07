function Set-HiveNightmareFix {
<#
.SYNOPSIS
    Sets Hive Nightmare Fix.

.DESCRIPTION
    Sets Hive Nightmare Fix.

.EXAMPLE
    Set-HiveNightmareFix
    Runs Set-HiveNightmareFix.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-HiveNightmareFix
#>

        [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-HiveNightmareFix')]
    Param ()
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        if ($PSCmdlet.ShouldProcess("$env:windir\system32\config\*.*", "Enable inheritance")) {
            icacls $env:windir\system32\config\*.* /inheritance:e
        }
        if ($PSCmdlet.ShouldProcess('Shadow copies', "Delete all")) {
            vssadmin.exe delete shadows /all
        }
    }
    else {Write-Error "Must be ran as admin"}
}
