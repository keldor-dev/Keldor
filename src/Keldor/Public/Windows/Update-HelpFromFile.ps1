function Update-HelpFromFile {
<#
.SYNOPSIS
    Updates Help From File.

.DESCRIPTION
    Updates Help From File.

.PARAMETER SourcePath
    Specifies the path to use.

.EXAMPLE
    Update-HelpFromFile
    Runs Update-HelpFromFile.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Update-HelpFromFile
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Update-HelpFromFile')]
    param(
        [Parameter()]
        [Alias('Path','Folder','Source')]
        [string]$SourcePath
    )

    if ([string]::IsNullOrWhiteSpace($Source)) {
        $SourcePath = ($Global:KeldorConfig).HelpFolder
    }
    if (Test-KeldorAdministrator) {Update-Help -SourcePath $SourcePath -Module * -Force}
    else {Write-Error "Must be ran as administrator."}
}
