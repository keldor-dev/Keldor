function Open-CMTrace {
<#
.SYNOPSIS
    Opens CM Trace.

.DESCRIPTION
    Opens CM Trace.

.PARAMETER Path
    Specifies the path to use.

.EXAMPLE
    Open-CMTrace
    Runs Open-CMTrace.

.OUTPUTS
    None

.NOTES
    Author: Skyler Hart
    Created: 2021-10-19 15:07:45
    Last Edit: 2021-10-19 15:15:48
    Keywords:

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-CMTrace
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-CMTrace')]
    [Alias('Open-CCMTrace','CMTrace','CCMTrace')]
    param(
        [Parameter(
            Mandatory=$false
        )]
        [Alias('File','FileName','Name','Source')]
        [string]$Path
    )

    $lcm = "C:\Windows\CCM\CMTrace.exe"
    $ncm = ($Global:KeldorConfig).CMTrace

    if ([string]::IsNullOrWhiteSpace($Path)) {
        if (Test-Path $lcm) {Start-Process $lcm}
        else {Start-Process $ncm}
    }
    else {
        if (Test-Path $lcm) {Start-Process $lcm -ArgumentList $Path}
        else {Start-Process $ncm -ArgumentList $Path}
    }
}
