function Open-HomeDrive {
<#
.NOTES
    Author: Skyler Hart
    Created: 2020-11-03 15:03:52
    Last Edit: 2020-11-03 15:03:52
    Keywords:
.LINK
    https://docs.keldor.dev/powershell/keldor/Open-HomeDrive
#>
        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-HomeDrive')]
    Param ()
explorer.exe $env:HOMESHARE
}
