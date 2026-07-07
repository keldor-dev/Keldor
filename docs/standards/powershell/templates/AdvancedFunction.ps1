function Get-KeldorThing {
    <#
    .SYNOPSIS
        Gets a Keldor thing.

    .DESCRIPTION
        Gets a Keldor thing from the specified path.

    .PARAMETER Path
        Specifies the path to inspect.

    .EXAMPLE
        Get-KeldorThing -Path .

        Gets a Keldor thing from the current directory.

    .OUTPUTS
        Keldor.Thing

    .LINK
        https://docs.keldor.dev/powershell/keldor/Get-KeldorThing
    #>
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-KeldorThing')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    process {
        [pscustomobject]@{
            PSTypeName = 'Keldor.Thing'
            Path       = $Path
            Exists     = Test-Path -Path $Path
        }
    }
}
