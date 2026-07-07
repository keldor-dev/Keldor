function Set-AutoLoadPreference {
<#
.SYNOPSIS
    Sets Auto Load Preference.

.DESCRIPTION
    Sets Auto Load Preference.

.PARAMETER mode
    Specifies the mode value.

.EXAMPLE
    Set-AutoLoadPreference
    Runs Set-AutoLoadPreference.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-AutoLoadPreference
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-AutoLoadPreference')]
    Param (
        [Parameter(Mandatory=$false, Position=0)]
        [ValidateSet("All","None")]
        $mode = "All"
    )
    if ($PSCmdlet.ShouldProcess('PSModuleAutoloadingPreference', "Set to $mode")) {
        $PSModuleAutoloadingPreference = $mode
    }
}
