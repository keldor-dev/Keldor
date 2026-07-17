function Get-KeldorLinuxDistribution {
    <#
    .SYNOPSIS
        Gets normalized Linux distribution information.

    .DESCRIPTION
        Parses Linux os-release data as inert text and returns normalized distribution identity. On Windows and macOS,
        the command writes a non-terminating InvalidOperation error and returns no success object.

    .PARAMETER ComputerName
        Specifies computers reachable through configured PowerShell remoting. Keldor must be installed on each target.

    .PARAMETER PSSession
        Specifies existing PowerShell sessions to reuse. Keldor must be installed in each remote session.

    .PARAMETER Credential
        Specifies a credential for ComputerName remoting.

    .EXAMPLE
        Get-KeldorLinuxDistribution

        Gets distribution information on Linux.

    .EXAMPLE
        Get-PSSession | Get-KeldorLinuxDistribution | Select-Object ComputerName, PrettyName, VersionId

        Gets distribution information through existing Linux sessions.

    .INPUTS
        System.String and System.Management.Automation.Runspaces.PSSession.

    .OUTPUTS
        Keldor.LinuxDistribution

    .NOTES
        This command is Linux-specific. It never executes os-release as a shell script.

    .LINK
        https://docs.keldor.dev/powershell/keldor/Get-KeldorLinuxDistribution
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'Local',
        HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-KeldorLinuxDistribution'
    )]
    [OutputType('Keldor.LinuxDistribution')]
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
            Type       = 'LinuxDistribution'
            TargetKind = $PSCmdlet.ParameterSetName
        }
        if ($ComputerName) { $parameters.ComputerName = $ComputerName }
        if ($PSSession) { $parameters.PSSession = $PSSession }
        if ($Credential) { $parameters.Credential = $Credential }
        Invoke-KeldorInventoryCollection @parameters
    }
}
