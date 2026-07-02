function Mount-HomeDrive {
<#
.NOTES
    Author: Skyler Hart
    Created: 2020-11-03 14:58:38
    Last Edit: 2020-11-03 14:58:38
    Keywords:
.LINK
    https://docs.keldor.dev
#>
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Mount-HomeDrive')]
    [Alias('Add-HomeDrive')]
    param()
    net use $env:HOMEDRIVE $env:HOMESHARE /persistent:yes
}
