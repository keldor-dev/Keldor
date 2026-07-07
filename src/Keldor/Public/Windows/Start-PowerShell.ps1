function Start-PowerShell {
<#
.SYNOPSIS
    Starts Power Shell.

.DESCRIPTION
    Starts Power Shell.

.PARAMETER Console
    Specifies whether to enable the Console option.

.PARAMETER ISE
    Specifies whether to enable the ISE option.

.PARAMETER VSC
    Specifies whether to enable the VSC option.

.PARAMETER RunAs
    Specifies whether to enable the Run As option.

.EXAMPLE
    Start-PowerShell
    Runs Start-PowerShell.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 10/24/2017 14:41:52
    LASTEDIT: 10/24/2017 16:41:21
    KEYWORDS:

.LINK
    https://docs.keldor.dev/powershell/keldor/Start-PowerShell
#>





    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Start-PowerShell')]
    [Alias('Open-PowerShell')]
    Param (
        [Parameter(Mandatory=$false)]
        [switch]$Console,

        [Parameter(Mandatory=$false)]
        [switch]$ISE,

        [Parameter(Mandatory=$false)]
        [switch]$VSC,

        [Parameter(Mandatory=$false)]
        [switch]$RunAs
    )


    if ($true -notin $Console,$ISE,$VSC) {
        if ($Host.Name -eq 'ConsoleHost') {
            if ($RunAs) {
                if ($PSCmdlet.ShouldProcess('PowerShell ISE', "Start elevated")) {Start-Process "$env:windir\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe" -Verb RunAs}
            }
            else {
                if ($PSCmdlet.ShouldProcess('PowerShell ISE', "Start")) {Start-Process "$env:windir\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe"}
            }
        }
        else {
            if ($RunAs) {
                if ($PSCmdlet.ShouldProcess('powershell.exe', "Start elevated")) {Start-Process powershell.exe -Verb RunAs}
            }
            else {
                if ($PSCmdlet.ShouldProcess('powershell.exe', "Start")) {Start-Process powershell.exe}
            }
        }
    }
    else {
        if ($Console) {
            if ($RunAs) {
                if ($PSCmdlet.ShouldProcess('powershell.exe', "Start elevated")) {Start-Process powershell.exe -Verb RunAs}
            }
            else {
                if ($PSCmdlet.ShouldProcess('powershell.exe', "Start")) {Start-Process powershell.exe}
            }
        }
        elseif ($ISE) {
            if ($RunAs) {
                if ($PSCmdlet.ShouldProcess('PowerShell ISE', "Start")) {Start-Process "$env:windir\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe"}
            }
            else {
                if ($PSCmdlet.ShouldProcess('PowerShell ISE', "Start")) {Start-Process "$env:windir\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe"}
            }
        }
        elseif ($VSC) {
            if ($RunAs) {
                if ($PSCmdlet.ShouldProcess('Visual Studio Code', "Start")) {Start-Process "$env:programfiles\Microsoft VS Code\Code.exe"}
            }
            else {
                if ($PSCmdlet.ShouldProcess('Visual Studio Code', "Start")) {Start-Process "$env:programfiles\Microsoft VS Code\Code.exe"}
            }
        }
    }
}
