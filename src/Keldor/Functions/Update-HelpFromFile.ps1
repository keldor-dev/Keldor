function Update-HelpFromFile {
<#
.NOTES
    Author: Skyler Hart
    Created: 2021-12-17 22:54:13
    Last Edit: 2021-12-17 22:54:13
    Keywords:
    Other:
    Requires:
        -RunAsAdministrator
.LINK
    https://docs.keldor.dev
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
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {Update-Help -SourcePath $SourcePath -Module * -Force}
    else {Write-Error "Must be ran as administrator."}
}
