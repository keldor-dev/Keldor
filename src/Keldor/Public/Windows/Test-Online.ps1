function Test-Online {
    <#
    .SYNOPSIS
        Tests ICMP reachability using the historical Keldor output shape.

    .DESCRIPTION
        Deprecated compatibility wrapper for Test-ResponseTime. It tests ICMP echo response only; it does not determine
        whether a computer is generally online or whether PowerShell remoting is available.

    .PARAMETER ComputerName
        Specifies one or more ICMP targets.

    .EXAMPLE
        Test-Online -ComputerName server01

        Tests ICMP reachability and returns Name and Status compatibility properties.

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Use Test-ResponseTime for explicit ICMP latency testing. Removal is targeted for Keldor 1.0.0.

    .LINK
        https://docs.keldor.dev/powershell/keldor/Test-Online
    #>
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Test-Online')]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    begin {
        Write-Verbose 'Test-Online is deprecated; use Test-ResponseTime for explicit ICMP testing.'
    }

    process {
        foreach ($target in $ComputerName) {
            try {
                $response = Test-ResponseTime -RemoteAddress $target -ErrorAction Stop
                $status = if ($response) { 'Online' } else { 'Offline' }
            } catch {
                $status = 'Comm error'
            }

            [pscustomobject][ordered]@{
                Name   = $target
                Status = $status
            }
        }
    }
}
