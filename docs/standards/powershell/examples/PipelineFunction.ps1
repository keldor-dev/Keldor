function Get-KeldorComputerThing {
    <#
    .SYNOPSIS
        Gets a Keldor computer thing.

    .DESCRIPTION
        Demonstrates a pipeline-aware ComputerName pattern for Keldor PowerShell commands.

    .PARAMETER ComputerName
        Specifies one or more computer names.

    .EXAMPLE
        'SERVER01' | Get-KeldorComputerThing

        Gets a Keldor computer thing for SERVER01.

    .OUTPUTS
        Keldor.Computer.Thing

    .LINK
        https://docs.keldor.dev/powershell/keldor/Get-KeldorComputerThing
    #>
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-KeldorComputerThing')]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    process {
        foreach ($Computer in $ComputerName) {
            [pscustomobject]@{
                PSTypeName   = 'Keldor.Computer.Thing'
                ComputerName = $Computer
                Status       = 'Unknown'
                CheckedAt    = Get-Date
            }
        }
    }
}
