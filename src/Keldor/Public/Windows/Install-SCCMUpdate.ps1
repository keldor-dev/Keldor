function Install-SCCMUpdate {
    <#
.SYNOPSIS
    Installs pending Configuration Manager software updates.

.DESCRIPTION
    Uses the Configuration Manager client SDK to install all pending software updates on local or remote computers.

.PARAMETER ComputerName
    Specifies the name of one or more computers.

.EXAMPLE
    Install-SCCMUpdate

    Installs pending updates on the local Configuration Manager client.

.EXAMPLE
    Install-SCCMUpdate -ComputerName 'SERVER01'

    Installs pending updates on SERVER01 through PowerShell remoting.

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
