function Set-WindowState {
<#
.SYNOPSIS
    Sets Window State.

.DESCRIPTION
    Sets Window State.

.PARAMETER Style
    Specifies the Style value.

.PARAMETER MainWindowHandle
    Specifies the Main Window Handle value.

.EXAMPLE
    Set-WindowState
    Runs Set-WindowState.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-WindowState
#>

    # source: https://gist.github.com/jakeballard/11240204
        [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-WindowState')]
param(
        [Parameter()]
        [ValidateSet('FORCEMINIMIZE','HIDE','MAXIMIZE','MINIMIZE','RESTORE',
                    'SHOW','SHOWDEFAULT','SHOWMAXIMIZED','SHOWMINIMIZED',
                    'SHOWMINNOACTIVE','SHOWNA','SHOWNOACTIVATE','SHOWNORMAL')]
        $Style = 'SHOW',

        [Parameter()]
        $MainWindowHandle = (Get-Process -id $pid).MainWindowHandle
    )
    $WindowStates = @{
        'FORCEMINIMIZE'   = 11
        'HIDE'            = 0
        'MAXIMIZE'        = 3
        'MINIMIZE'        = 6
        'RESTORE'         = 9
        'SHOW'            = 5
        'SHOWDEFAULT'     = 10
        'SHOWMAXIMIZED'   = 3
        'SHOWMINIMIZED'   = 2
        'SHOWMINNOACTIVE' = 7
        'SHOWNA'          = 8
        'SHOWNOACTIVATE'  = 4
        'SHOWNORMAL'      = 1
    }

    $Win32ShowWindowAsync = Add-Type -memberDefinition @"
    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -name "Win32ShowWindowAsync" -namespace Win32Functions -passThru

    if ($PSCmdlet.ShouldProcess($MainWindowHandle, "Set window state to $Style")) {
        $Win32ShowWindowAsync::ShowWindowAsync($MainWindowHandle, $WindowStates[$Style]) | Out-Null
        Write-Verbose ("Set Window Style '{1} on '{0}'" -f $MainWindowHandle, $Style)
    }
}
