function Get-ComputerModel {
    <#
    .SYNOPSIS
        Gets computer models using the historical Keldor output shape.

    .DESCRIPTION
        Deprecated compatibility wrapper for Get-KeldorHardwareInfo. The wrapper preserves historical property names
        while delegating all hardware discovery to the normalized command.

    .PARAMETER ComputerName
        Specifies one or more computers. Omit this parameter for the local computer.

    .EXAMPLE
        Get-ComputerModel

        Gets the local model using the historical output shape.

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Use Get-KeldorHardwareInfo for new automation. DomainRole cannot be reconstructed reliably from the normalized
        hardware contract and is null. Removal is targeted for Keldor 1.0.0.

    .LINK
        https://docs.keldor.dev/powershell/keldor/Get-ComputerModel
    #>
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-ComputerModel')]
    [OutputType([pscustomobject])]
    [Alias('Get-Model')]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName
    )

    begin {
        Write-Verbose 'Get-ComputerModel is deprecated; use Get-KeldorHardwareInfo.'
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
                DomainRole   = $null
                Manufacturer = if ($result.IsSuccessful) { $result.Manufacturer } else { 'NA' }
                Model        = if ($result.IsSuccessful) { $result.Model } else { 'NA' }
                PorV         = if ($result.IsVirtualMachine -eq $true) {
                    'Virtual'
                } elseif ($result.IsVirtualMachine -eq $false) {
                    'Physical'
                } else {
                    $null
                }
                Type         = $result.SystemType
            }
        }
    }
}
