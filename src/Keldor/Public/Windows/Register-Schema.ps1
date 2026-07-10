function Register-Schema {
    <#
.SYNOPSIS
    Registers Schema.

.DESCRIPTION
    Registers Schema.

.EXAMPLE
    Register-Schema
    Runs Register-Schema.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Register-Schema
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Register-Schema')]
    param ()
    if (Test-Path $env:windir\System32\schmmgmt.dll) {
        regsvr32.exe schmmgmt.dll
    } else {
        Write-Warning "schmmgmt.dll not found. Please ensure Active Directory tools are installed."
    }
}
