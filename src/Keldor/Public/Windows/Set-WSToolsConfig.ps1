function Set-WSToolsConfig {
<#
.SYNOPSIS
    Sets WS Tools Config.

.DESCRIPTION
    Sets WS Tools Config.

.EXAMPLE
    Set-WSToolsConfig
    Runs Set-WSToolsConfig.

.OUTPUTS
    None

.NOTES
    Author: Skyler Hart
    Created: 2020-04-17 15:00:06
    Last Edit: 2020-04-17 15:00:06

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-WSToolsConfig
#>





        [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-WSToolsConfig')]
    Param ()
$ModuleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ConfigPath = Join-Path -Path $ModuleRoot -ChildPath 'config.ps1'
if ($PSCmdlet.ShouldProcess($ConfigPath, "Open WSTools config")) {
    PowerShell_Ise $ConfigPath
}
}
