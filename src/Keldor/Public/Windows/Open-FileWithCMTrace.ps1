function Open-FileWithCMTrace {
<#
.SYNOPSIS
    Opens File With CM Trace.

.DESCRIPTION
    Opens File With CM Trace.

.PARAMETER FileName
    Specifies the File Name value.

.EXAMPLE
    Open-FileWithCMTrace -FileName <value>
    Runs Open-FileWithCMTrace.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-FileWithCMTrace
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-FileWithCMTrace')]
    [Alias('Open-Log')]
    param(
        [Parameter(
            Mandatory=$true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('File','Path')]
        [string[]]$FileName
    )
    $Continue = $false
    if (Test-Path "c:\Windows\ccm\CMTrace.exe") {
        $app = "c:\Windows\ccm\CMTrace.exe"
        $Continue = $true
    }
    elseif (Test-Path "C:\ProgramData\OSI\CMTrace.exe") {
        $app = "C:\ProgramData\OSI\CMTrace.exe"
        $Continue = $true
    }
    elseif (Test-Path "J:\Patches\CMTrace.exe") {
        $app = "J:\Patches\CMTrace.exe"
        $Continue = $true
    }
    else {
        Write-Error "Cannot find CMTrace.exe"
        $Continue = $false
    }

    if ($Continue) {
        foreach ($file in $FileName) {
            Start-Process $app -ArgumentList $file
        }
    }
}
