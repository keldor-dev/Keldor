function Get-KeldorExampleInventory {
    <#
    .SYNOPSIS
        Gets example inventory for rich pipeline input.

    .DESCRIPTION
        Demonstrates a documented InputObject contract. Each input object must expose a non-empty ComputerName property.

    .PARAMETER InputObject
        Specifies objects with a ComputerName property. A Source property is optional.

    .EXAMPLE
        [pscustomobject]@{ ComputerName = 'server01'; Source = 'CMDB' } | Get-KeldorExampleInventory

        Returns normalized example inventory.

    .OUTPUTS
        Keldor.ExampleInventory

    .LINK
        https://docs.keldor.dev/powershell/keldor/Get-KeldorExampleInventory
    #>
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-KeldorExampleInventory')]
    [OutputType('Keldor.ExampleInventory')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [object[]]$InputObject
    )

    process {
        foreach ($item in $InputObject) {
            if ([string]::IsNullOrWhiteSpace([string]$item.ComputerName)) {
                $message = 'InputObject must provide a non-empty ComputerName property.'
                $exception = New-Object System.ArgumentException $message, 'InputObject'
                $errorRecord = New-Object System.Management.Automation.ErrorRecord(
                    $exception,
                    'Keldor.InputObject.MissingComputerName',
                    [System.Management.Automation.ErrorCategory]::InvalidArgument,
                    $item
                )
                $PSCmdlet.WriteError($errorRecord)
                continue
            }

            $result = [pscustomobject][ordered]@{
                ComputerName = [string]$item.ComputerName
                Platform     = 'Unknown'
                Source       = [string]$item.Source
                DiscoveredAt = [datetimeoffset]::UtcNow
            }
            $result.PSObject.TypeNames.Insert(0, 'Keldor.ExampleInventory')
            $result
        }
    }
}
