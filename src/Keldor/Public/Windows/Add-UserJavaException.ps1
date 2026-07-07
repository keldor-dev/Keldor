function Add-UserJavaException {
<#
.SYNOPSIS
    Adds Java exception.

.DESCRIPTION
    Will add a website entry to $env:USERPROFILE\AppData\LocalLow\Sun\Java\Deployment\security\exception.sites.

.PARAMETER URI
    Specifies the URI of the website you want to add to the exception.sites file. Must be in the format https://docs.keldor.dev/powershell/keldor/Add-UserJavaException.

.EXAMPLE
    Add-UserJavaException https://docs.keldor.dev/powershell/keldor/Add-UserJavaException
    Example of how to use this cmdlet

.OUTPUTS
    No output

.LINK
    https://docs.keldor.dev/powershell/keldor/Add-UserJavaException
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Add-UserJavaException')]
    param(
        [Parameter(
            HelpMessage = "Enter the address of the website.",
            Mandatory=$true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Site','URL','Address','Website')]
        [string]$URI
    )
    Add-Content -Path "$env:USERPROFILE\AppData\LocalLow\Sun\Java\Deployment\security\exception.sites" -Value "$URI"
}
