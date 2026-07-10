function Get-LinesOfCode {
    <#
.SYNOPSIS
    Gets Lines Of Code.

.DESCRIPTION
    Gets Lines Of Code.

.PARAMETER Path
    Specifies the path to use.

.EXAMPLE
    Get-LinesOfCode -Path <value>
    Runs Get-LinesOfCode.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-LinesOfCode
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-LinesOfCode')]
    param(
        [Parameter(
            HelpMessage = "Enter the path of the folder you want to count lines of PowerShell and JSON code for",
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    (Get-ChildItem -Path $Path -Recurse | Where-Object { $_.extension -in '.ps1', '.psm1', '.psd1', '.json' } | Select-String "^\s*$" -NotMatch).Count
}
