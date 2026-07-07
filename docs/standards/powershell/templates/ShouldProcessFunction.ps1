function Remove-KeldorThing {
    <#
    .SYNOPSIS
        Removes a Keldor thing.

    .DESCRIPTION
        Removes a Keldor thing from the specified path.

    .PARAMETER Path
        Specifies the path to remove.

    .EXAMPLE
        Remove-KeldorThing -Path . -WhatIf

        Shows what would happen without removing anything.

    .OUTPUTS
        None

    .LINK
        https://docs.keldor.dev/powershell/keldor/Remove-KeldorThing
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High', HelpUri = 'https://docs.keldor.dev/powershell/keldor/Remove-KeldorThing')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    process {
        if ($PSCmdlet.ShouldProcess($Path, 'Remove Keldor thing')) {
            Remove-Item -Path $Path -Force
        }
    }
}
