function Get-KeldorHardwareInfo {
    <#
    .SYNOPSIS
        Gets normalized hardware information.

    .DESCRIPTION
        Returns physical or virtual hardware identity, processor capacity, memory capacity, firmware, and
        evidence-based virtualization information for Windows, Linux, and macOS.

    .PARAMETER ComputerName
        Specifies computers reachable through configured PowerShell remoting. Keldor must be installed on each target.

    .PARAMETER PSSession
        Specifies existing PowerShell sessions to reuse.

    .PARAMETER Credential
        Specifies a credential for ComputerName remoting.

    .EXAMPLE
        Get-KeldorHardwareInfo | Select-Object Manufacturer, Model, SerialNumber

        Gets the local manufacturer, model, and serial number.

    .EXAMPLE
        'server01', 'server02' | Get-KeldorHardwareInfo | Where-Object IsVirtualMachine

        Gets hardware information from configured remoting targets and selects identified virtual machines.

    .EXAMPLE
        Get-PSSession | Get-KeldorHardwareInfo | ConvertTo-Json -Depth 3

        Reuses sessions and serializes hardware inventory as JSON.

    .INPUTS
        System.String and System.Management.Automation.Runspaces.PSSession.

    .OUTPUTS
        Keldor.HardwareInfo

    .NOTES
        IsVirtualMachine is null when available evidence cannot distinguish physical and virtual hardware.

    .LINK
        https://docs.keldor.dev/powershell/keldor/Get-KeldorHardwareInfo
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'Local',
        HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-KeldorHardwareInfo'
    )]
    [OutputType('Keldor.HardwareInfo')]
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
            TargetKind = $PSCmdlet.ParameterSetName
        }
        if ($ComputerName) { $parameters.ComputerName = $ComputerName }
        if ($PSSession) { $parameters.PSSession = $PSSession }
        if ($Credential) { $parameters.Credential = $Credential }
        # Collection owns remoting and platform details; this command owns its output contract.
        $snapshots = @(Get-KeldorInventorySnapshot @parameters)
        foreach ($snapshot in $snapshots) {
            $value = $Snapshot.Hardware
            $memoryBytes = if ($null -ne $value.MemoryBytes) { [long]$value.MemoryBytes } else { $null }
            $result = [pscustomobject][ordered]@{
                ComputerName           = $Snapshot.ComputerName
                Platform               = $Snapshot.Platform
                Manufacturer           = $value.Manufacturer
                Model                  = $value.Model
                SerialNumber           = $value.SerialNumber
                SystemUuid             = $value.SystemUuid
                AssetTag               = $value.AssetTag
                ChassisType            = $value.ChassisType
                SystemType             = $value.SystemType
                Architecture           = $value.Architecture
                ProcessorManufacturer  = $value.ProcessorManufacturer
                ProcessorModel         = $value.ProcessorModel
                ProcessorCount         = $value.ProcessorCount
                PhysicalCoreCount      = $value.PhysicalCoreCount
                LogicalProcessorCount  = $value.LogicalProcessorCount
                MemoryBytes            = $memoryBytes
                MemoryGB               = if ($null -ne $memoryBytes) { [double]($memoryBytes / 1GB) } else { $null }
                FirmwareManufacturer   = $value.FirmwareManufacturer
                FirmwareVersion        = $value.FirmwareVersion
                FirmwareReleaseDate    = $value.FirmwareReleaseDate
                IsVirtualMachine       = $value.IsVirtualMachine
                VirtualizationPlatform = $value.VirtualizationPlatform
                Source                 = $value.Source
                IsSuccessful           = $Snapshot.IsSuccessful
                ErrorCategory          = $Snapshot.ErrorCategory
                ErrorCode              = $Snapshot.ErrorCode
                ErrorMessage           = $Snapshot.ErrorMessage
                CollectedAt            = $Snapshot.CollectedAt
            }
            $result.PSObject.TypeNames.Insert(0, 'Keldor.HardwareInfo')
            $result
        }
    }
}
