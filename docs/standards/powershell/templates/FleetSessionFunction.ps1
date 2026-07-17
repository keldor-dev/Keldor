function Invoke-KeldorExampleSessionQuery {
    <#
    .SYNOPSIS
        Runs an example query by computer name or reusable session.

    .DESCRIPTION
        Demonstrates meaningful ComputerName and PSSession parameter sets. A supplied session is reused.

    .PARAMETER ComputerName
        Specifies one or more target computers.

    .PARAMETER PSSession
        Specifies one or more existing PowerShell sessions to reuse.

    .EXAMPLE
        'server01' | Invoke-KeldorExampleSessionQuery

        Runs the example query by computer name.

    .EXAMPLE
        Get-PSSession | Invoke-KeldorExampleSessionQuery

        Reuses each supplied session.

    .OUTPUTS
        Keldor.RemoteCommandResult

    .LINK
        https://docs.keldor.dev/powershell/keldor/Invoke-KeldorExampleSessionQuery
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'ComputerName',
        HelpUri = 'https://docs.keldor.dev/powershell/keldor/Invoke-KeldorExampleSessionQuery'
    )]
    [OutputType('Keldor.RemoteCommandResult')]
    param(
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'ComputerName',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('HostName', 'DnsHostName', 'Name')]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Session',
            ValueFromPipeline = $true
        )]
        [ValidateNotNull()]
        [System.Management.Automation.Runspaces.PSSession[]]$PSSession
    )

    process {
        $targets = if ($PSCmdlet.ParameterSetName -eq 'Session') { $PSSession } else { $ComputerName }

        foreach ($target in $targets) {
            $startedAt = [datetimeoffset]::UtcNow
            $resolvedComputerName = if ($PSCmdlet.ParameterSetName -eq 'Session') {
                $target.ComputerName
            } else {
                [string]$target
            }
            $transport = if ($PSCmdlet.ParameterSetName -eq 'Session') { 'ExistingSession' } else { 'Auto' }

            # Replace this example output with Invoke-Command. Pass the supplied PSSession directly in Session mode.
            $commandOutput = [pscustomobject]@{ ExampleValue = 1 }
            $completedAt = [datetimeoffset]::UtcNow
            $result = [pscustomobject][ordered]@{
                ComputerName  = $resolvedComputerName
                IsSuccessful  = $true
                Output        = $commandOutput
                ErrorCategory = $null
                ErrorCode     = $null
                ErrorMessage  = $null
                StartedAt     = $startedAt
                CompletedAt   = $completedAt
                Duration      = $completedAt - $startedAt
                Transport     = $transport
                AttemptCount  = 1
            }
            $result.PSObject.TypeNames.Insert(0, 'Keldor.RemoteCommandResult')
            $result
        }
    }
}
