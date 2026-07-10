function Get-HWPerformanceScore {
    <#
.SYNOPSIS
    Gets HW Performance Score.

.DESCRIPTION
    Gets HW Performance Score.

.PARAMETER ComputerName
    Specifies the computer name to use.

.PARAMETER MaxThreads
    Specifies the Max Threads value.

.PARAMETER SleepTimer
    Specifies the Sleep Timer value.

.PARAMETER MaxResultTime
    Specifies the Max Result Time value.

.EXAMPLE
    Get-HWPerformanceScore
    Runs Get-HWPerformanceScore.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-HWPerformanceScore
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-HWPerformanceScore')]
    param (
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName = $env:COMPUTERNAME,

        [Parameter()]
        [int32]$MaxThreads = 5,

        [Parameter()]
        $SleepTimer = 200,

        [Parameter()]
        $MaxResultTime = 1200
    )
    begin {
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
                [string]$comp
            )
            if ($comp -eq $env:COMPUTERNAME) {
                Get-CimInstance -ClassName Win32_WinSAT -ErrorAction Stop
            } else {
                Get-CimInstance -ClassName Win32_WinSAT -ComputerName $comp -ErrorAction Stop
            }
        }# end code block
        $Jobs = @()
    }
    process {
        Write-Progress -Activity "Preloading threads" -Status "Starting Job $($jobs.count)"
        foreach ($Object in $ComputerName) {
            $PowershellThread = [powershell]::Create().AddScript($Code)
            $PowershellThread.AddArgument($Object.ToString()) | Out-Null
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
                -Activity "Getting hardware performance scores. Waiting for Jobs - $($MaxThreads - $($RunspacePool.GetAvailableRunspaces())) of $MaxThreads threads running" `
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
