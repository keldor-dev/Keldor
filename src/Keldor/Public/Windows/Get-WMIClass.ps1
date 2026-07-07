#Look up "root\WMI" or "root\CCM" using Get-ComputerWMINamespaces
function Get-WMIClass {
<#
.SYNOPSIS
    Gets WMI Class.

.DESCRIPTION
    Gets WMI Class.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Get-WMIClass
    Runs Get-WMIClass.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-WMIClass
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-WMIClass')]
    Param (
        [Parameter(
            Mandatory=$false,
            Position=0
        )]
        [Alias('Host','Name','Computer','CN')]
        [string]$ComputerName = "$env:COMPUTERNAME"
    )

    Get-WmiObject -Namespace root\WMI -ComputerName $ComputerName -List
}
