function Get-Drive {
    <#
    .NOTES
        Author: Skyler Hart
        Created: 2020-04-19 20:29:58
        Last Edit: 2020-04-19 20:29:58

    .LINK
        https://docs.keldor.dev/powershell/keldor/Get-Drive
    #>
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-Drive')]
    [Alias('drive')]
    param()
    Get-PSDrive -Name *
}
