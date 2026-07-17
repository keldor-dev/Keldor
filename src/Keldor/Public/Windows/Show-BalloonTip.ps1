function Show-BalloonTip {
    <#
.SYNOPSIS
    Shows Balloon Tip.

.DESCRIPTION
    Shows Balloon Tip.

.PARAMETER Text
    Specifies the Text value.

.PARAMETER Title
    Specifies the Title value.

.PARAMETER Icon
    Specifies the Icon value.

.PARAMETER Timeout
    Specifies the Timeout value.

.EXAMPLE
    Show-BalloonTip -Text 'Maintenance is complete.' -Title 'Keldor'

    Displays an informational balloon tip for 30 seconds.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Show-BalloonTip
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Show-BalloonTip')]
    [Alias('tip')]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Text,

        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Error', 'Warning')]
        [string]$Icon = 'Info',

        [Parameter(Mandatory = $false)]
        [int32]$Timeout = 30000
    )

    Add-Type -AssemblyName System.Windows.Forms
    if ($null -eq $PopUp) { $PopUp = New-Object System.Windows.Forms.NotifyIcon }
    $Path = Get-Process -Id $PID | Select-Object -ExpandProperty Path
    $PopUp.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($Path)
    $PopUp.BalloonTipIcon = $Icon
    $PopUp.BalloonTipText = $Text
    $PopUp.BalloonTipTitle = $Title
    $PopUp.Visible = $true
    $PopUp.ShowBalloonTip($Timeout)
}
