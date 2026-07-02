function Open-NetLogonLog {
<#
.SYNOPSIS
    Opens Net Logon Log.

.DESCRIPTION
    Opens Net Logon Log.

.EXAMPLE
    Open-NetLogonLog
    Runs Open-NetLogonLog.

.OUTPUTS
    None

.NOTES
    Author: Skyler Hart
    Created: 2021-06-22 17:50:31
    Last Edit: 2021-06-22 17:50:31
    Keywords:

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-NetLogonLog
#>





        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-NetLogonLog')]
    Param ()
$Continue = $false
    $file = "$env:windir\debug\netlogon.log"
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
            try {
                Start-Process $app -ArgumentList $file -ErrorAction Stop
            }
            catch {
                Write-Error "Could not find or did not have permission to open $file"
            }
        }
    }
}
