function Update-McAfeeSecurity {
<#
.SYNOPSIS
    Updates Mc Afee Security.

.DESCRIPTION
    Updates Mc Afee Security.

.EXAMPLE
    Update-McAfeeSecurity
    Runs Update-McAfeeSecurity.

.OUTPUTS
    None

.NOTES
    Author: Skyler Hart
    Created: 2021-10-30 03:14:47
    Last Edit: 2021-10-30 03:14:47
    Keywords:

.LINK
    https://docs.keldor.dev/powershell/keldor/Update-McAfeeSecurity
#>





        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Update-McAfeeSecurity')]
    Param ()
$fpath = "${env:ProgramFiles(x86)}\McAfee\Endpoint Security\Threat Prevention\amcfg.exe"
    if (Test-Path $fpath) {
        Start-Process $fpath -ArgumentList "/update"
    }
    else {
        Write-Error "McAfee Endpoint Security Threat Protection not installed"
    }
}
