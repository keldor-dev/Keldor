function Update-ModulesFromLocalRepo {
    <#
.SYNOPSIS
    Updates Modules From Local Repo.

.DESCRIPTION
    Updates Modules From Local Repo.

.PARAMETER ComputerName
    Specifies the computer name to use.

.PARAMETER MaxThreads
    Specifies the Max Threads value.

.PARAMETER SleepTimer
    Specifies the Sleep Timer value.

.PARAMETER MaxResultTime
    Specifies the Max Result Time value.

.EXAMPLE
    Update-ModulesFromLocalRepo
    Runs Update-ModulesFromLocalRepo.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Update-ModulesFromLocalRepo
#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Update-ModulesFromLocalRepo')]
    param (
        [Parameter(
            Mandatory = $false,
            Position = 0,
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
        $config = $Global:KeldorConfig
        $repo = $config.LocalPSRepo

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
                [string]$repo
            )
            $rmodules = Get-ChildItem $repo | Where-Object { $_.Attributes -eq "Directory" } | Select-Object Name, FullName
            if ($comp -eq $env:COMPUTERNAME) {
                $lmodules = Get-ChildItem $env:ProgramFiles\WindowsPowerShell\Modules | Where-Object { $_.Attributes -eq "Directory" } | Select-Object Name, FullName
            }#if local
            else {
                $lmodules = Get-ChildItem "\\$comp\c$\Program Files\WindowsPowerShell\Modules" | Where-Object { $_.Attributes -eq "Directory" } | Select-Object Name, FullName
            }#if remote

            foreach ($mod in $lmodules) {
                $modname = $mod.Name
                $modpath = $mod.FullName

                $rpath = $rmodules | Where-Object { $_.Name -eq $modname } | Select-Object -ExpandProperty FullName

                if ([string]::IsNullOrWhiteSpace($rpath)) {
                    #do nothing
                } else {
                    Write-Output "$(Get-Date) - ${comp}: Updating $modname"
                    robocopy $rpath $modpath /mir /mt:4 /njh /njs /r:3 /w:10 | Out-Null
                }
            }
        }#end code block
        $Jobs = @()
    }
    process {
        Write-Progress -Activity "Copying PowerShell modules" -Status "Starting Job $($jobs.count)"
        foreach ($Object in $ComputerName) {
            $PowershellThread = [powershell]::Create().AddScript($Code)
            $PowershellThread.AddArgument($Object.ToString()) | Out-Null
            $PowershellThread.AddArgument($repo.ToString()) | Out-Null
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
                -Activity "Waiting for Jobs - $($MaxThreads - $($RunspacePool.GetAvailableRunspaces())) of $MaxThreads threads running" `
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
