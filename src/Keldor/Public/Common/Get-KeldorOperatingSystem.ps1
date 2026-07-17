function Get-KeldorOperatingSystem {
    <#
    .SYNOPSIS
        Gets normalized operating-system information.

    .DESCRIPTION
        Returns operating-system identity, version, role, architecture, installation, and boot information for the
        local system or configured PowerShell-remoting targets.

    .PARAMETER ComputerName
        Specifies computers reachable through configured PowerShell remoting. Keldor must be installed on each target.

    .PARAMETER PSSession
        Specifies existing PowerShell sessions to reuse. Keldor must be installed in each remote session.

    .PARAMETER Credential
        Specifies a credential for ComputerName remoting. Credential contents are never returned.

    .EXAMPLE
        Get-KeldorOperatingSystem

        Gets operating-system information for the local system.

    .EXAMPLE
        'server01', 'server02' | Get-KeldorOperatingSystem

        Gets operating-system information through configured PowerShell remoting.

    .EXAMPLE
        Get-PSSession | Get-KeldorOperatingSystem | Where-Object IsServer

        Reuses existing sessions and filters server operating systems.

    .INPUTS
        System.String and System.Management.Automation.Runspaces.PSSession.

    .OUTPUTS
        Keldor.OperatingSystem

    .NOTES
        ComputerName uses the host's standard PowerShell-remoting configuration and does not modify it.

    .LINK
        https://docs.keldor.dev/powershell/keldor/Get-KeldorOperatingSystem
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'Local',
        HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-KeldorOperatingSystem'
    )]
    [OutputType('Keldor.OperatingSystem')]
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
            Type       = 'OperatingSystem'
            TargetKind = $PSCmdlet.ParameterSetName
        }
        if ($ComputerName) { $parameters.ComputerName = $ComputerName }
        if ($PSSession) { $parameters.PSSession = $PSSession }
        if ($Credential) { $parameters.Credential = $Credential }
        Invoke-KeldorInventoryCollection @parameters
    }
}
