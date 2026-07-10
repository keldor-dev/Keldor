function Set-AutoLoadPreference {
    <#
.SYNOPSIS
    Sets Auto Load Preference.

.DESCRIPTION
    Sets Auto Load Preference.

.PARAMETER Mode
    Specifies the Mode value.

.EXAMPLE
    Set-AutoLoadPreference
    Runs Set-AutoLoadPreference.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-AutoLoadPreference
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-AutoLoadPreference')]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateSet("All", "None")]
        $Mode = "All"
    )
    if ($PSCmdlet.ShouldProcess('PSModuleAutoloadingPreference', "Set to $Mode")) {
        $PSModuleAutoloadingPreference = $Mode
    }
}
