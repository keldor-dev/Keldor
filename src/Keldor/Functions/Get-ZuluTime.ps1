function Get-ZuluTime {
<#
.NOTES
    Author: Skyler Hart
    Created: 2021-06-10 22:28:39
    Last Edit: 2021-06-10 22:28:39
.LINK
    https://docs.keldor.dev
#>
        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-ZuluTime')]
    Param ()
(Get-Date).ToUniversalTime()
}
