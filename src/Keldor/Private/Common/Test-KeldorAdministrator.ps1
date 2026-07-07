function Test-KeldorAdministrator {
<#
.SYNOPSIS
    Tests whether the current process is running as administrator.

.DESCRIPTION
    Returns true when the current Windows identity is in the local Administrators role.
    Returns false on non-Windows platforms or when the check cannot be completed.

.OUTPUTS
    System.Boolean

.LINK
    https://docs.keldor.dev/powershell/keldor/Test-KeldorAdministrator
#>

    [CmdletBinding()]
    param()

    try {
        if ((Get-KeldorPlatform) -ne 'Windows') {
            return $false
        }

        $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)

        return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    catch {
        return $false
    }
}
