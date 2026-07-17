function Get-KeldorPlatform {
    <#
    .SYNOPSIS
        Gets the current operating-system platform.

    .DESCRIPTION
        Identifies the operating-system family and returns exactly Windows, macOS, Linux, or Unknown.

        Get-KeldorPlatform identifies only the operating-system family. It does not return the operating-system edition,
        distribution, architecture, build, or version. It supports Windows PowerShell 5.1 and supported PowerShell 7
        release lines beginning with PowerShell 7.4.

    .EXAMPLE
        Get-KeldorPlatform

        Returns the operating-system family for the current PowerShell session.

    .EXAMPLE
        if ((Get-KeldorPlatform) -eq 'Windows') {
            Write-Output 'Running on Windows.'
        }

        Uses the fixed platform contract to run platform-specific logic.

    .OUTPUTS
        System.String

    .LINK
        https://docs.keldor.dev/powershell/keldor/Get-KeldorPlatform
    #>
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-KeldorPlatform')]
    [OutputType([string])]
    param()

    Get-KeldorBootstrapPlatform
}
