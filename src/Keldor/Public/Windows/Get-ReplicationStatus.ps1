function Get-ReplicationStatus {
<#
.SYNOPSIS
    Gets Replication Status.

.DESCRIPTION
    Gets Replication Status.

.EXAMPLE
    Get-ReplicationStatus
    Runs Get-ReplicationStatus.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-ReplicationStatus
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-ReplicationStatus')]
    [Alias('replsum')]
    param()
    repadmin /replsum
}
