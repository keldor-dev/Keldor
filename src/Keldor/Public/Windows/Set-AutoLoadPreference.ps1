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

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 02/01/2018 10:23:26
    LASTEDIT: 02/01/2018 10:23:26
    KEYWORDS:
    REQUIRES:
    -Version 2.0 only doesn't apply to Version 3.0 or newer

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-AutoLoadPreference
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-AutoLoadPreference')]
    Param (
        [Parameter(Mandatory=$false, Position=0)]
        [ValidateSet("All","None")]
        $mode = "All"
    )
    $PSModuleAutoloadingPreference = $mode
}
