function Get-WMINameSpace {
<#
.SYNOPSIS
    Gets WMI Name Space.

.DESCRIPTION
    Gets WMI Name Space.

.PARAMETER ComputerName
    Specifies the computer name to use.

.PARAMETER Namespace
    Specifies the Namespace value.

.EXAMPLE
    Get-WMINameSpace
    Runs Get-WMINameSpace.

.OUTPUTS
    System.Object

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 09/21/2017 13:05:21
    LASTEDIT: 09/21/2017 13:05:21
    KEYWORDS:

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-WMINameSpace
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-WMINameSpace')]
    Param (
        [Parameter(
            Mandatory=$false,
            Position=0
        )]
        [Alias('Host','Name','Computer','CN')]
        [string]$ComputerName = "$env:COMPUTERNAME",

        [string]$Namespace = "root"
    )

    Get-WmiObject -Namespace $Namespace -Class "__Namespace" -ComputerName $ComputerName | Select-Object Name
}
