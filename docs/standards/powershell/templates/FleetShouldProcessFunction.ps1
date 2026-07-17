function Set-KeldorExampleFleetState {
    <#
    .SYNOPSIS
        Sets example state on one or more computers.

    .DESCRIPTION
        Demonstrates pipeline binding, per-target ShouldProcess, and normalized state-change results.

    .PARAMETER ComputerName
        Specifies one or more target computers.

    .EXAMPLE
        'server01', 'server02' | Set-KeldorExampleFleetState -WhatIf

        Describes the state change for each target without applying it.

    .OUTPUTS
        Keldor.ExampleStateChangeResult

    .LINK
        https://docs.keldor.dev/powershell/keldor/Set-KeldorExampleFleetState
    #>
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium',
        HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-KeldorExampleFleetState'
    )]
    [OutputType('Keldor.ExampleStateChangeResult')]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('HostName', 'DnsHostName', 'Name')]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName
    )

    process {
        foreach ($target in $ComputerName) {
            if ($PSCmdlet.ShouldProcess($target, 'Set example fleet state')) {
                # Apply exactly one target's state change here.
                $result = [pscustomobject][ordered]@{
                    ComputerName = $target
                    IsSuccessful = $true
                    HasChanges   = $true
                    ErrorMessage = $null
                    CompletedAt  = [datetimeoffset]::UtcNow
                }
                $result.PSObject.TypeNames.Insert(0, 'Keldor.ExampleStateChangeResult')
                $result
            }
        }
    }
}
