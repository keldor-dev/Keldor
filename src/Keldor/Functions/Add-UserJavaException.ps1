function Add-UserJavaException {
    <#
    .SYNOPSIS
        Adds Java exception.

    .DESCRIPTION
        Will add a website entry to $env:USERPROFILE\AppData\LocalLow\Sun\Java\Deployment\security\exception.sites.

    .PARAMETER URI
        Specifies the URI of the website you want to add to the exception.sites file. Must be in the
        format https://docs.keldor.dev.

    .EXAMPLE
        C:\PS>Add-UserJavaException https://docs.keldor.dev
        Example of how to use this cmdlet

    .INPUTS
        System.String

    .OUTPUTS
        No output

    .COMPONENT
        Keldor

    .FUNCTIONALITY
        java, exception

    .NOTES
        Author: Skyler Hart
        Created: 2019-03-20 10:40:11
        Last Edit: 2021-12-20 00:15:00

    .LINK
        https://docs.keldor.dev
    #>
    [CmdletBinding()]
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
