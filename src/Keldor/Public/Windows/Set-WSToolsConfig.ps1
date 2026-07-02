function Set-WSToolsConfig {
<#
.NOTES
    Author: Skyler Hart
    Created: 2020-04-17 15:00:06
    Last Edit: 2020-04-17 15:00:06
.LINK
    https://docs.keldor.dev/powershell/keldor/Set-WSToolsConfig
#>
        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-WSToolsConfig')]
    Param ()
$ModuleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
PowerShell_Ise (Join-Path -Path $ModuleRoot -ChildPath 'config.ps1')
}
