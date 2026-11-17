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
            TargetKind = $PSCmdlet.ParameterSetName
        }
        if ($ComputerName) { $parameters.ComputerName = $ComputerName }
        if ($PSSession) { $parameters.PSSession = $PSSession }
        if ($Credential) { $parameters.Credential = $Credential }
        # Collection owns remoting and platform details; this command owns its output contract.
        $snapshots = @(Get-KeldorInventorySnapshot @parameters)
        foreach ($snapshot in $snapshots) {
            if ($snapshot.Platform -and $snapshot.Platform -ne 'Linux') {
                $errorParameters = @{
                    Message      = "Get-KeldorLinuxDistribution is not applicable to platform '$($snapshot.Platform)'."
                    Category     = 'InvalidOperation'
                    ErrorId      = 'Keldor.LinuxDistribution.NotApplicable'
                    TargetObject = $snapshot.ComputerName
                }
                Write-Error @errorParameters
                continue
            }

            $value = $Snapshot.LinuxDistribution
            $result = [pscustomobject][ordered]@{
                ComputerName    = $Snapshot.ComputerName
                Platform        = $Snapshot.Platform
                Name            = $value.Name
                Id              = $value.Id
                IdLike          = $value.IdLike
                PrettyName      = $value.PrettyName
                Version         = $value.Version
                VersionId       = $value.VersionId
                VersionCodename = $value.VersionCodename
                BuildId         = $value.BuildId
                Variant         = $value.Variant
                VariantId       = $value.VariantId
                HomeUrl         = $value.HomeUrl
                SupportUrl      = $value.SupportUrl
                BugReportUrl    = $value.BugReportUrl
                SourcePath      = $value.SourcePath
                IsSuccessful    = $Snapshot.IsSuccessful
                ErrorCategory   = $Snapshot.ErrorCategory
                ErrorCode       = $Snapshot.ErrorCode
                ErrorMessage    = $Snapshot.ErrorMessage
                CollectedAt     = $Snapshot.CollectedAt
            }
            $result.PSObject.TypeNames.Insert(0, 'Keldor.LinuxDistribution')
            $result
        }
    }
}
