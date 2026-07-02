function Get-SCCMPendingUpdate {
<#
.SYNOPSIS
    Short description

.DESCRIPTION
    Long description

.PARAMETER ComputerName
    Specifies the name of one or more computers.

.EXAMPLE
    Get-SCCMPendingUpdate
    Example of how to use this cmdlet

.EXAMPLE
    Get-SCCMPendingUpdate -PARAMETER
    Another example of how to use this cmdlet but with a parameter or switch.

.OUTPUTS
    System.Management.Automation.PSCustomObject

.NOTES
    Author: Skyler Hart
    Created: 2023-03-29 22:31:19
    Last Edit: 2023-03-29 22:31:19
    Other:
    Requires:
    -Module ActiveDirectory
    -PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
    -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-SCCMPendingUpdate
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-SCCMPendingUpdate')]
    [Alias()]
    param(
        [Parameter(
            #HelpMessage = "Enter one or more computer names separated by commas.",
            Mandatory=$false#,
            #Position=0,
            #ValueFromPipeline = $true
        )]
        [Alias('Host','Name','Computer','CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    Process {
        foreach ($Comp in $ComputerName) {
            if ($Comp -eq $env:COMPUTERNAME) {
                $Updates = (Get-WmiObject -Query "SELECT * FROM CCM_SoftwareUpdate" -namespace "ROOT\ccm\ClientSDK")
                foreach ($Update in $Updates) {
                    [PSCustomObject]@{
                        ComputerName = $Update.PSComputerName
                        Update = $Update.Name
                    }#new object
                }
            }
            else {
                Invoke-Command -ComputerName $Comp -ScriptBlock {#DevSkim: ignore DS104456
                    $Updates = (Get-WmiObject -Query "SELECT * FROM CCM_SoftwareUpdate" -namespace "ROOT\ccm\ClientSDK")
                    foreach ($Update in $Updates) {
                        [PSCustomObject]@{
                            ComputerName = $Update.PSComputerName
                            Update = $Update.Name
                        }#new object
                    }
                }
            }#not local
        }
    }
}
