function Register-ADSIEdit {
<#
.SYNOPSIS
    Registers ADSI Edit.

.DESCRIPTION
    Registers ADSI Edit.

.EXAMPLE
    Register-ADSIEdit
    Runs Register-ADSIEdit.

.OUTPUTS
    None

.NOTES
    Author: Skyler Hart
    Created: 2020-04-19 19:53:38
    Last Edit: 2022-09-04 12:18:51
    Keywords:

.LINK
    https://docs.keldor.dev/powershell/keldor/Register-ADSIEdit
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Register-ADSIEdit')]
    [Alias('Initialize-ADSIEdit','Enable-ADSIEdit')]
    param()

    if (Test-Path $env:windir\System32\adsiedit.dll) {
        regsvr32.exe adsiedit.dll
    }
    else {
        Write-Warning "adsiedit.dll not found. Please ensure Active Directory tools are installed."
    }
}
