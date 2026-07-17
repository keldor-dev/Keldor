function Get-SerialNumber {
    <#
    .SYNOPSIS
        Gets serial numbers using the historical Keldor output shape.

    .DESCRIPTION
        Deprecated compatibility wrapper for Get-KeldorHardwareInfo. The wrapper projects the normalized hardware
        result and contains no independent serial-number discovery.

    .PARAMETER ComputerName
        Specifies one or more computers. Omit this parameter for the local computer.

    .EXAMPLE
        Get-SerialNumber

        Gets the local serial number using the historical output shape.

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Use Get-KeldorHardwareInfo for new automation. Removal is targeted for Keldor 1.0.0.

    .LINK
        https://docs.keldor.dev/powershell/keldor/Get-SerialNumber
    #>
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-SerialNumber')]
    [OutputType([pscustomobject])]
    [Alias('Get-SN')]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName
    )

    begin {
        Write-Verbose 'Get-SerialNumber is deprecated; use Get-KeldorHardwareInfo.'
    }

    process {
        $results = if ($PSBoundParameters.ContainsKey('ComputerName')) {
            Get-KeldorHardwareInfo -ComputerName $ComputerName
        } else {
            Get-KeldorHardwareInfo
        }

        foreach ($result in $results) {
            [pscustomobject][ordered]@{
                ComputerName = $result.ComputerName
                SerialNumber = if ($result.IsSuccessful -and $result.SerialNumber) { $result.SerialNumber } else { 'NA' }
            }
        }
    }
}
