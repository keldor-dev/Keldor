function Sync-InTune {
    <#
.SYNOPSIS
    Will sync device with InTune/MEM.

.DESCRIPTION
    Will initiate the sync process with InTune/Microsoft EndPoint Manager to receive new policies and report information.

.EXAMPLE
    Sync-InTune
    Example of how to use this cmdlet.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Sync-InTune
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Sync-InTune')]
    [Alias('Sync-MEM')]
    param()

    try {
        Get-ScheduledTask -TaskName PushLaunch -ErrorAction Stop | Start-ScheduledTask
    } catch {
        Write-Warning "Device is not InTune/Microsoft Endpoint Manager (MEM) managed."
    }
}
