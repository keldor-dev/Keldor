function Test-KeldorRemoteCommandName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return $Name -cmatch '^[A-Z][A-Za-z0-9]*-Keldor[A-Za-z0-9]+$'
}
