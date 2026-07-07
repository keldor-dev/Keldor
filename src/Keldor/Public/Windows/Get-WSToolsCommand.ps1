function Get-WSToolsCommand {
<#
.SYNOPSIS
    Gets WS Tools Command.

.DESCRIPTION
    Gets WS Tools Command.

.EXAMPLE
    Get-WSToolsCommand
    Runs Get-WSToolsCommand.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-WSToolsCommand
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-WSToolsCommand')]
    [Alias('WSToolsCommands')]
    param()
    $commands = (Get-Module Keldor | Select-Object ExportedCommands).ExportedCommands
    $commands.Values | Select-Object CommandType,Name,Source
}
