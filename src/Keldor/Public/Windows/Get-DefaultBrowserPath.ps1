function Get-DefaultBrowserPath {
    <#
.SYNOPSIS
    Gets Default Browser Path.

.DESCRIPTION
    Gets Default Browser Path.

.EXAMPLE
    Get-DefaultBrowserPath
    Runs Get-DefaultBrowserPath.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-DefaultBrowserPath
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-DefaultBrowserPath')]
    param ()
    New-PSDrive -Name HKCR -PSProvider Registry -Root Hkey_Classes_Root | Out-Null
    $BrowserPath = ((Get-ItemProperty 'HKCR:\http\shell\open\command').'(default)').Split('"')[1]
    return $BrowserPath
    Remove-PSDrive -Name HKCR -Force -ErrorAction SilentlyContinue | Out-Null
}
