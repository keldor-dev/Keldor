function Open-ADSIEdit {
<#
.SYNOPSIS
    Opens ADSI Edit.

.DESCRIPTION
    Opens ADSI Edit.

.EXAMPLE
    Open-ADSIEdit
    Runs Open-ADSIEdit.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-ADSIEdit
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-ADSIEdit')]
    [Alias('adsi')]
    param()
    try {
        $ErrorActionPreference = "Stop"
        adsiedit.msc
    }
    catch {
        try {
            Register-ADSIEdit
            Start-Sleep 1
            adsiedit.msc
        }
        catch {
            Write-Output "Active Directory snapins are not installed/enabled."
        }
    }
}
