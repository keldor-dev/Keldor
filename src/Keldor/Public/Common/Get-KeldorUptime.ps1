function Get-KeldorUptime {
    <#
    .SYNOPSIS
        Gets normalized system uptime.

    .DESCRIPTION
        Returns native boot time, current time, TimeSpan uptime, and numeric totals for local or remote systems.

    .PARAMETER ComputerName
        Specifies computers reachable through configured PowerShell remoting. Keldor must be installed on each target.

    .PARAMETER PSSession
        Specifies existing PowerShell sessions to reuse.

    .PARAMETER Credential
        Specifies a credential for ComputerName remoting.

    .EXAMPLE
        Get-KeldorUptime | Select-Object ComputerName, LastBootTime, Uptime

        Gets local uptime using native value types.

    .EXAMPLE
        Get-PSSession | Get-KeldorUptime | Sort-Object TotalDays -Descending

        Reuses sessions and sorts targets by uptime.

    .INPUTS
        System.String and System.Management.Automation.Runspaces.PSSession.

    .OUTPUTS
        Keldor.Uptime

    .NOTES
        Get-UpTime remains a deprecated Windows compatibility wrapper for its historical output shape.

    .LINK
        https://docs.keldor.dev/powershell/keldor/Get-KeldorUptime
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'Local',
        HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-KeldorUptime'
    )]
    [OutputType('Keldor.Uptime')]
    param(
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'ComputerName',
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('HostName', 'DnsHostName')]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName,

        [Parameter(Mandatory = $true, ParameterSetName = 'PSSession', ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [System.Management.Automation.Runspaces.PSSession[]]$PSSession,

        [Parameter(ParameterSetName = 'ComputerName')]
        [pscredential]$Credential
    )

    process {
        $parameters = @{
            Type       = 'Uptime'
            TargetKind = $PSCmdlet.ParameterSetName
        }
        if ($ComputerName) { $parameters.ComputerName = $ComputerName }
        if ($PSSession) { $parameters.PSSession = $PSSession }
        if ($Credential) { $parameters.Credential = $Credential }
        Invoke-KeldorInventoryCollection @parameters
    }
}
