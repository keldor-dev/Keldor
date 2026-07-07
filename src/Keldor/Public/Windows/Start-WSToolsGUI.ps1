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

.LINK
    https://docs.keldor.dev/powershell/keldor/Start-WSToolsGUI
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Start-WSToolsGUI')]
    [Alias('wsgui','wstgui','Start-WSToolsTrayApp')]
    param()
    $ModuleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $TrayAppPath = Join-Path -Path $ModuleRoot -ChildPath 'WSTools_SystemTrayApp.ps1'
    if ($PSCmdlet.ShouldProcess($TrayAppPath, "Start WSTools GUI")) {
        Start-Process powershell.exe -ArgumentList "`$host.ui.RawUI.WindowTitle = 'Keldor Taskbar App'; & '$TrayAppPath'"
    }
}
