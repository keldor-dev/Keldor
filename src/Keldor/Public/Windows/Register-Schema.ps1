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

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 02/12/2018 20:10:54
    LASTEDIT: 2022-09-04 12:20:42
    KEYWORDS:
    REQUIRES:
    -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Register-Schema
#>





        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Register-Schema')]
    Param ()
if (Test-Path $env:windir\System32\schmmgmt.dll) {
        regsvr32.exe schmmgmt.dll
    }
    else {
        Write-Warning "schmmgmt.dll not found. Please ensure Active Directory tools are installed."
    }
}
