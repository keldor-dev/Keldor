function Start-WSToolsGUI {
<#
.SYNOPSIS
    Starts WS Tools GUI.

.DESCRIPTION
    Starts WS Tools GUI.

.EXAMPLE
    Start-WSToolsGUI
    Runs Start-WSToolsGUI.

.OUTPUTS
    None

.NOTES
    Author: Skyler Hart
    Created: 2021-10-30 00:55:48
    Last Edit: 2021-10-30 00:55:48
    Keywords:

.LINK
    https://docs.keldor.dev/powershell/keldor/Start-WSToolsGUI
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Start-WSToolsGUI')]
    [Alias('wsgui','wstgui','Start-WSToolsTrayApp')]
    param()
    $ModuleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $TrayAppPath = Join-Path -Path $ModuleRoot -ChildPath 'WSTools_SystemTrayApp.ps1'
    Start-Process powershell.exe -ArgumentList "`$host.ui.RawUI.WindowTitle = 'Keldor Taskbar App'; & '$TrayAppPath'"
}
