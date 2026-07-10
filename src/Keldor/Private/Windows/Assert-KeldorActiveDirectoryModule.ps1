function Assert-KeldorActiveDirectoryModule {
    <#
.SYNOPSIS
    Requires the ActiveDirectory module.

.DESCRIPTION
    Throws a terminating error when the ActiveDirectory module is unavailable or cannot be imported.

.PARAMETER Import
    Imports the ActiveDirectory module before returning.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Assert-KeldorActiveDirectoryModule
#>

    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Import
    )

    $status = Test-KeldorActiveDirectoryModule -Import:$Import -Quiet
    if (!$status.Available -or ($Import -and !$status.Imported)) {
        throw $status.Message
    }
}
