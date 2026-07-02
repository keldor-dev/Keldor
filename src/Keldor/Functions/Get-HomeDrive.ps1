function Get-HomeDrive {
    <#
    .NOTES
        Author: Skyler Hart
        Created: 2020-11-03 15:02:09
        Last Edit: 2020-11-03 15:02:09

    .LINK
        https://docs.keldor.dev/powershell/keldor/Get-HomeDrive
    #>
        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-HomeDrive')]
    Param ()
$env:HOMESHARE
}
