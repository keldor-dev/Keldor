function Test-KeldorExampleHealth {
    <#
    .SYNOPSIS
        Tests an example health condition on one or more computers.

    .DESCRIPTION
        Demonstrates pipeline target binding and returns one normalized result for every target, including targets that
        cannot be checked.

    .PARAMETER ComputerName
        Specifies one or more computer names, fully qualified domain names, or IP addresses.

    .EXAMPLE
        'server01', 'server02' | Test-KeldorExampleHealth

        Returns a health result for each target.

    .OUTPUTS
        Keldor.ExampleHealthResult

    .LINK
        https://docs.keldor.dev/powershell/keldor/Test-KeldorExampleHealth
    #>
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Test-KeldorExampleHealth')]
    [OutputType('Keldor.ExampleHealthResult')]
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
            $checkedAt = [datetimeoffset]::UtcNow

            try {
                # Replace this deterministic example condition with the real check.
                if ($target -eq 'unavailable') {
                    throw 'The example target is unavailable.'
                }

                $isHealthy = $true
                $result = [pscustomobject][ordered]@{
                    ComputerName  = $target
                    CheckName     = 'Example'
                    IsHealthy     = $isHealthy
                    Status        = if ($isHealthy) { 'Passed' } else { 'Failed' }
                    Severity      = if ($isHealthy) { 'Informational' } else { 'Critical' }
                    Message       = $null
                    CurrentValue  = 1
                    ExpectedValue = 1
                    ErrorCategory = $null
                    ErrorCode     = $null
                    ErrorMessage  = $null
                    CheckedAt     = $checkedAt
                }
            } catch {
                $result = [pscustomobject][ordered]@{
                    ComputerName  = $target
                    CheckName     = 'Example'
                    IsHealthy     = $null
                    Status        = 'Unknown'
                    Severity      = 'Warning'
                    Message       = 'The check could not be completed.'
                    CurrentValue  = $null
                    ExpectedValue = 1
                    ErrorCategory = [string]$_.CategoryInfo.Category
                    ErrorCode     = $_.FullyQualifiedErrorId
                    ErrorMessage  = $_.Exception.Message
                    CheckedAt     = $checkedAt
                }

                Write-Error -ErrorRecord $_
            }

            $result.PSObject.TypeNames.Insert(0, 'Keldor.ExampleHealthResult')
            $result
        }
    }
}
