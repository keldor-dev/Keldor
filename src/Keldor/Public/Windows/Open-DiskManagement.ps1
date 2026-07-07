function Open-DiskManagement {
<#
.SYNOPSIS
    Opens Disk Management.

.DESCRIPTION
    Opens Disk Management.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Open-DiskManagement
    Runs Open-DiskManagement.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-DiskManagement
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-DiskManagement')]
    Param (
        [Parameter(Mandatory=$false, Position=0)]
        [Alias('Host','Name','Computer','CN')]
        [string]$ComputerName = "$env:COMPUTERNAME"
    )
    diskmgmt.msc /computer:\\$ComputerName
}
