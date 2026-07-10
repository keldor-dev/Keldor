function Install-SCCMUpdate {
    <#
.SYNOPSIS
    Short description

.DESCRIPTION
    Long description

.PARAMETER ComputerName
    Specifies the name of one or more computers.

.EXAMPLE
    Install-SCCMUpdate
    Example of how to use this cmdlet

.EXAMPLE
    Install-SCCMUpdate -PARAMETER
    Another example of how to use this cmdlet but with a parameter or switch.

.OUTPUTS
    System.Management.Automation.PSCustomObject

.LINK
    https://docs.keldor.dev/powershell/keldor/Install-SCCMUpdate
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Install-SCCMUpdate')]
    [Alias()]
    param(
        [Parameter(
            #HelpMessage = "Enter one or more computer names separated by commas.",
            Mandatory = $false#,
            #Position=0,
            #ValueFromPipeline = $true
        )]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    begin {}
    process {
        foreach ($Comp in $ComputerName) {
            if ($Comp -eq $env:COMPUTERNAME) {
                ([wmiclass]'ROOT\ccm\ClientSDK:CCM_SoftwareUpdatesManager').InstallUpdates([System.Management.ManagementObject[]] (get-wmiobject -query 'SELECT * FROM CCM_SoftwareUpdate' -namespace 'ROOT\ccm\ClientSDK'))
            } else {
                Invoke-Command -ComputerName $Comp -ScriptBlock { #DevSkim: ignore DS104456
                    ([wmiclass]'ROOT\ccm\ClientSDK:CCM_SoftwareUpdatesManager').InstallUpdates([System.Management.ManagementObject[]] (get-wmiobject -query 'SELECT * FROM CCM_SoftwareUpdate' -namespace 'ROOT\ccm\ClientSDK'))
                }
            }#not local
        }
    }
    end {}
}
