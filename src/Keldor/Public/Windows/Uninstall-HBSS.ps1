function Uninstall-HBSS {
    <#
.SYNOPSIS
    Uninstalls HBSS.

.DESCRIPTION
    Uninstalls HBSS.

.PARAMETER ObjectList
    Specifies the Object List value.

.PARAMETER MaxThreads
    Specifies the Max Threads value.

.PARAMETER SleepTimer
    Specifies the Sleep Timer value.

.PARAMETER MaxResultTime
    Specifies the Max Result Time value.

.EXAMPLE
    Uninstall-HBSS
    Runs Uninstall-HBSS.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Uninstall-HBSS
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Uninstall-HBSS')]
    [Alias('Uninstall-ENS', 'Uninstall-ESS')]
    param (
        [Parameter(
            HelpMessage = "Enter one or more computer names separated by commas.",
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('Host', 'Name', 'Computer', 'CN', 'ComputerName')]
        [string[]]$ObjectList,

        [Parameter()]
        [int32]$MaxThreads = 5,

        [Parameter()]
        $SleepTimer = 200,

        [Parameter()]
        $MaxResultTime = 1200
    )

    begin {
        if ([string]::IsNullOrWhiteSpace($ObjectList)) {
            $ObjectList = $env:COMPUTERNAME
        }
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
            try {
                Invoke-WMIMethod -Class Win32_Process -ComputerName $comp -Name Create -ArgumentList 'cmd /c "C:\Program Files\McAfee\Agent\x86\FrmInst.exe" /Remove=Agent /Silent' -ErrorAction Stop | Out-Null
                Start-Sleep -Seconds 30
                Get-WmiObject -Class Win32_Product -Filter "Name like 'McAfee Agent%'" -ComputerName $Comp -ErrorAction SilentlyContinue | Remove-WmiObject -ErrorAction SilentlyContinue
                [PSCustomObject]@{
                    ComputerName = $comp
                    Program      = "McAfee ENS (HBSS) Agent"
                    Status       = "Removal Initialized"
                }#new object
            }#try
            catch {
                [PSCustomObject]@{
                    ComputerName = $comp
                    Program      = "McAfee ENS (HBSS) Agent"
                    Status       = "Failed"
                }#new object
            }#catch
        }#end code block
        $Jobs = @()
    }
    process {
        Write-Progress -Activity "Preloading threads" -Status "Starting Job $($jobs.count)"
        foreach ($Object in $ObjectList) {
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
        while (@($Jobs | Where-Object { $null -ne $_.Handle }).count -gt 0) {
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
