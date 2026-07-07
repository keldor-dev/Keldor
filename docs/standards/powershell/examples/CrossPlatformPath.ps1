function Join-KeldorExamplePath {
    <#
    .SYNOPSIS
        Joins a Keldor example path.

    .DESCRIPTION
        Demonstrates cross-platform path construction using Join-Path instead of hardcoded separators.

    .PARAMETER RootPath
        Specifies the root path.

    .PARAMETER ChildPath
        Specifies the child path.

    .EXAMPLE
        Join-KeldorExamplePath -RootPath . -ChildPath docs

        Joins the current directory with the docs child path.

    .OUTPUTS
        System.String

    .LINK
        https://docs.keldor.dev/powershell/keldor/Join-KeldorExamplePath
    #>
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Join-KeldorExamplePath')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RootPath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ChildPath
    )

    process {
        Join-Path -Path $RootPath -ChildPath $ChildPath
    }
}
