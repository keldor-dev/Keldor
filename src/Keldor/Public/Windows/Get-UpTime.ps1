function Get-UpTime {
    <#
    .SYNOPSIS
        Gets uptime using the historical Keldor output shape.

    .DESCRIPTION
        Deprecated compatibility wrapper for Get-KeldorUptime. The wrapper contains no independent uptime discovery
        and projects normalized results into the historical properties.

    .PARAMETER ComputerName
        Specifies one or more computers. Omit this parameter for the local computer.

    .EXAMPLE
        Get-UpTime

        Gets local uptime using the historical output shape.

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Use Get-KeldorUptime for new automation. Removal is targeted for Keldor 1.0.0.

    .LINK
        https://docs.keldor.dev/powershell/keldor/Get-UpTime
    #>
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-UpTime')]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName
    )

    begin {
        Write-Verbose 'Get-UpTime is deprecated; use Get-KeldorUptime.'
    }

    process {
        $results = if ($PSBoundParameters.ContainsKey('ComputerName')) {
            Get-KeldorUptime -ComputerName $ComputerName
        } else {
            Get-KeldorUptime
        }

        foreach ($result in $results) {
            if ($result.IsSuccessful) {
                [pscustomobject][ordered]@{
                    ComputerName = $result.ComputerName
                    LastBoot     = $result.LastBootTime
                    Total        = ([math]::Round($result.TotalHours, 2)).ToString() + ' h'
                    Days         = $result.Uptime.Days
                    Hours        = $result.Uptime.Hours
                    Minutes      = $result.Uptime.Minutes
                    Seconds      = $result.Uptime.Seconds
                }
            } else {
                [pscustomobject][ordered]@{
                    ComputerName = $result.ComputerName
                    LastBoot     = 'Failed: Could not connect to computer'
                    Total        = ''
                    Days         = ''
                    Hours        = ''
                    Minutes      = ''
                    Seconds      = ''
                }
            }
        }
    }
}
