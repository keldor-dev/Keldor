function Get-KeldorKernel {
    <#
    .SYNOPSIS
        Gets normalized kernel and runtime information.

    .DESCRIPTION
        Returns kernel identity, architecture, host identity, boot identity, and process bitness for local or remote
        Windows, Linux, and macOS systems.

    .PARAMETER ComputerName
        Specifies computers reachable through configured PowerShell remoting. Keldor must be installed on each target.

    .PARAMETER PSSession
        Specifies existing PowerShell sessions to reuse.

    .PARAMETER Credential
        Specifies a credential for ComputerName remoting.

    .EXAMPLE
        Get-KeldorKernel

        Gets local kernel information.

    .EXAMPLE
        'server01', 'server02' | Get-KeldorKernel | Export-Csv -Path ./kernels.csv -NoTypeInformation

        Exports kernel information from configured remoting targets.

    .INPUTS
        System.String and System.Management.Automation.Runspaces.PSSession.

    .OUTPUTS
        Keldor.Kernel

    .NOTES
        Darwin may appear as KernelName on macOS; Platform remains normalized as macOS.

    .LINK
        https://docs.keldor.dev/powershell/keldor/Get-KeldorKernel
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'Local',
        HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-KeldorKernel'
    )]
    [OutputType('Keldor.Kernel')]
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
            Type       = 'Kernel'
            TargetKind = $PSCmdlet.ParameterSetName
        }
        if ($ComputerName) { $parameters.ComputerName = $ComputerName }
        if ($PSSession) { $parameters.PSSession = $PSSession }
        if ($Credential) { $parameters.Credential = $Credential }
        Invoke-KeldorInventoryCollection @parameters
    }
}
