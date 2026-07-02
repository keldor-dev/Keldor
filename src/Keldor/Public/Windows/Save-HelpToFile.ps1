function Save-HelpToFile {
<#
.SYNOPSIS
    Saves Help To File.

.DESCRIPTION
    Saves Help To File.

.PARAMETER DestinationPath
    Specifies the path to use.

.EXAMPLE
    Save-HelpToFile
    Runs Save-HelpToFile.

.OUTPUTS
    None

.NOTES
    Author: Skyler Hart
    Created: 2021-12-17 23:05:01
    Last Edit: 2021-12-17 23:05:01
    Keywords:
    Other:
    Requires:
    -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Save-HelpToFile
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Save-HelpToFile')]
    param(
        [Parameter()]
        [Alias('Path','Folder','Destination')]
        [string]$DestinationPath
    )

    if ([string]::IsNullOrWhiteSpace($Source)) {
        $DestinationPath = ($Global:KeldorConfig).HelpFolder
    }

    if (Test-Path $DestinationPath) {
        Save-Help -DestinationPath $DestinationPath -Module * -Force
    }
    else {
        Write-Error 'Destination folder "$DestinationPath" not found.'
    }
}
