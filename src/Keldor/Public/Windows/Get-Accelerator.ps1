function Get-Accelerator {
<#
.SYNOPSIS
    Gets Accelerator.

.DESCRIPTION
    Gets Accelerator.

.EXAMPLE
    Get-Accelerator
    Runs Get-Accelerator.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-Accelerator
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-Accelerator')]
    [Alias('Get-TypeAccelerators','accelerators')]
    param()

    [psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators")::get | Sort-Object Key
}
