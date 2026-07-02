function Get-WMINameSpace {
<#
.Notes
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
