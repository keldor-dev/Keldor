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

.NOTES
    AUTHOR: Skyler Hart
    CREATED: Sometime before 2017-08-07
    LASTEDIT: 08/18/2017 20:48:21
    KEYWORDS:

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-ReplicationStatus
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-ReplicationStatus')]
    [Alias('replsum')]
    param()
    repadmin /replsum
}
