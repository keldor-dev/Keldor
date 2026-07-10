function Install-WSTools {
    <#
.SYNOPSIS
    Installs/copies the Keldor PowerShell module to a remote computer.

.DESCRIPTION
    Copies the Keldor module from the location specified in the Keldor config file (config.ps1) for UpdatePath to the C:\Program Files\WindowsPowerShell\Modules\Keldor folder on the remote computer.

.PARAMETER ComputerName
    Specifies the name of one or more computers.

.PARAMETER MaxThreads
    Specifies the Max Threads value.

.PARAMETER SleepTimer
    Specifies the Sleep Timer value.

.PARAMETER MaxResultTime
    Specifies the Max Result Time value.

.EXAMPLE
    Install-WSTools COMPNAME
    How to install the Keldor PowerShell module on the remote computer COMPNAME.

.EXAMPLE
    Install-WSTools -ComputerName COMPNAME1,COMPNAME2
    How to install the Keldor PowerShell module on the remote computers COMPNAME1 and COMPNAME2.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Install-WSTools
#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSUseSingularNouns",
        "",
        Justification = "Keldor is the proper name for the module."
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Install-WSTools')]
    [Alias('Copy-WSTools', 'Push-WSTools')]
    param (
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('Host', 'Name', 'Computer', 'CN', 'common name')]
        [string[]] $ComputerName = $env:COMPUTERNAME,

        [Parameter()]
        [int32]$MaxThreads = 5,

        [Parameter()]
        $SleepTimer = 200,

        [Parameter()]
        $MaxResultTime = 1200
    )
    begin {
        $config = $Global:KeldorConfig
        $app = $config.UpdatePath
        $appname = "Keldor"

        $ISS = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
        $RunspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxThreads, $ISS, $Host)
        $RunspacePool.Open()
        $Code = {
            [CmdletBinding()]
            param (
                [Parameter(
                    Mandatory = $true,
                    Position = 0
                )]
                [string]$comp,

                [Parameter(
                    Mandatory = $true,
                    Position = 1
                )]
                [string]$app,

                [Parameter(
                    Mandatory = $true,
                    Position = 2
                )]
                [string]$appname
            )
            try {
                robocopy $app "\\$comp\c$\Program Files\WindowsPowerShell\Modules\$appname" /mir /mt:4 /r:3 /w:15 /njh /njs
            } catch {
                #
            }
        }#end code block
        $Jobs = @()
    }
    process {
        Write-Progress -Activity "Preloading threads" -Status "Starting Job $($jobs.count)"
        foreach ($Object in $ComputerName) {
            $PowershellThread = [powershell]::Create().AddScript($Code)
            $PowershellThread.AddArgument($Object.ToString()) | Out-Null
            $PowershellThread.AddArgument($app.ToString()) | Out-Null
            $PowershellThread.AddArgument($appname.ToString()) | Out-Null
            $PowershellThread.RunspacePool = $RunspacePool
            $Handle = $PowershellThread.BeginInvoke()
            $Job = "" | Select-Object Handle, Thread, object
            $Job.Handle = $Handle
            $Job.Thread = $PowershellThread
            $Job.Object = $Object.ToString()
            $Jobs += $Job
        }
    }
    end {
        $ResultTimer = Get-Date
        while (@($Jobs | Where-Object { $Null -ne $_.Handle }).count -gt 0) {
            $Remaining = "$($($Jobs | Where-Object {$_.Handle.IsCompleted -eq $False}).object)"
            if ($Remaining.Length -gt 60) {
                $Remaining = $Remaining.Substring(0, 60) + "..."
            }
            Write-Progress `
                -Activity "Copying $appname module to computers. Waiting for Jobs - $($MaxThreads - $($RunspacePool.GetAvailableRunspaces())) of $MaxThreads threads running" `
                -PercentComplete (($Jobs.count - $($($Jobs | Where-Object { $_.Handle.IsCompleted -eq $False }).count)) / $Jobs.Count * 100) `
                -Status "$(@($($Jobs | Where-Object {$_.Handle.IsCompleted -eq $False})).count) remaining - $remaining"
            foreach ($Job in $($Jobs | Where-Object { $_.Handle.IsCompleted -eq $True })) {
                $Job.Thread.EndInvoke($Job.Handle)
                $Job.Thread.Dispose()
                $Job.Thread = $Null
                $Job.Handle = $Null
                $ResultTimer = Get-Date
            }
            if (($(Get-Date) - $ResultTimer).totalseconds -gt $MaxResultTime) {
                Write-Error "Child script appears to be frozen, try increasing MaxResultTime"
                exit
            }
            Start-Sleep -Milliseconds $SleepTimer
        }
        $RunspacePool.Close() | Out-Null
        $RunspacePool.Dispose() | Out-Null
    }
}
