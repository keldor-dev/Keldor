function Open-LAPS {
<#
.SYNOPSIS
    Opens LAPS.

.DESCRIPTION
    Opens LAPS.

.EXAMPLE
    Open-LAPS
    Runs Open-LAPS.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-LAPS
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-LAPS')]
    [Alias('laps')]
    param()
    try {
        Start-Process 'C:\Program Files\LAPS\AdmPwd.UI' -ErrorAction Stop
    }
    catch [System.InvalidOperationException] {
        $err = $_.Exception.message.Trim()
        if ($err -match "cannot find the file") {
            Write-Error "LAPS admin console not installed"
        }
        else {
            Write-Error "Unknown error"
        }
    }
    catch {
        Get-Error -HowMany 1
    }
}
