function Get-KeldorSystemInfo {
    <#
    .SYNOPSIS
        Gets normalized cross-platform system inventory.

    .DESCRIPTION
        Composes Keldor operating-system, Linux distribution, kernel, uptime, and hardware result builders from one
        shared snapshot per target. The result is suitable for inventory, reporting, CMDB, and automation workflows.

    .PARAMETER ComputerName
        Specifies computers reachable through configured PowerShell remoting. Keldor must be installed on each target.

    .PARAMETER PSSession
        Specifies existing PowerShell sessions to reuse without reconnecting.

    .PARAMETER Credential
        Specifies a credential for ComputerName remoting. Credential contents are never returned.

    .EXAMPLE
        Get-KeldorSystemInfo

        Gets a normalized inventory object for the local system.

    .EXAMPLE
        'server01', 'server02' | Get-KeldorSystemInfo |
            Select-Object ComputerName, Platform, OperatingSystem, Model, SerialNumber

        Gets a concise inventory view from configured remoting targets.

    .EXAMPLE
        Get-PSSession | Get-KeldorSystemInfo | Export-Csv -Path ./system-inventory.csv -NoTypeInformation

        Reuses existing sessions and exports normalized inventory.

    .INPUTS
        System.String and System.Management.Automation.Runspaces.PSSession.

    .OUTPUTS
        Keldor.SystemInfo

    .NOTES
        Azure values remain null unless safe local metadata collection is added in a future compatible change. No cloud
        authentication or network metadata request occurs.

    .LINK
        https://docs.keldor.dev/powershell/keldor/Get-KeldorSystemInfo
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'Local',
        HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-KeldorSystemInfo'
    )]
    [OutputType('Keldor.SystemInfo')]
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
            $operatingSystem = $snapshot.OperatingSystem
            $kernel = $snapshot.Kernel
            $uptime = $snapshot.Uptime
            $hardware = $snapshot.Hardware
            $distribution = if ($snapshot.Platform -eq 'Linux') { $snapshot.LinuxDistribution } else { $null }
            $memoryBytes = if ($null -ne $hardware.MemoryBytes) { [long]$hardware.MemoryBytes } else { $null }

            $result = [pscustomobject][ordered]@{
                ComputerName             = $Snapshot.ComputerName
                Fqdn                     = $Snapshot.Fqdn
                Platform                 = $Snapshot.Platform
                OperatingSystem          = $operatingSystem.Name
                OperatingSystemCaption   = $operatingSystem.Caption
                OperatingSystemEdition   = $operatingSystem.Edition
                OperatingSystemVersion   = ConvertTo-KeldorVersion -Value $operatingSystem.Version
                OperatingSystemBuild     = $operatingSystem.BuildNumber
                LinuxDistribution        = if ($distribution) { $distribution.PrettyName } else { $null }
                LinuxDistributionId      = if ($distribution) { $distribution.Id } else { $null }
                LinuxDistributionVersion = if ($distribution) { $distribution.VersionId } else { $null }
                KernelName               = $kernel.KernelName
                KernelVersion            = $kernel.KernelVersion
                KernelRelease            = $kernel.KernelRelease
                Architecture             = $kernel.Architecture
                Manufacturer             = $hardware.Manufacturer
                Model                    = $hardware.Model
                SerialNumber             = $hardware.SerialNumber
                SystemUuid               = $hardware.SystemUuid
                AssetTag                 = $hardware.AssetTag
                ProcessorModel           = $hardware.ProcessorModel
                PhysicalCoreCount        = $hardware.PhysicalCoreCount
                LogicalProcessorCount    = $hardware.LogicalProcessorCount
                MemoryBytes              = $memoryBytes
                MemoryGB                 = if ($null -ne $memoryBytes) { [double]($memoryBytes / 1GB) } else { $null }
                LastBootTime             = $uptime.LastBootTime
                Uptime                   = $uptime.Uptime
                IsServer                 = $operatingSystem.IsServer
                IsDomainController       = $operatingSystem.IsDomainController
                IsVirtualMachine         = $hardware.IsVirtualMachine
                VirtualizationPlatform   = $hardware.VirtualizationPlatform
                PowerShellVersion        = ConvertTo-KeldorVersion -Value $Snapshot.PowerShellVersion
                PowerShellEdition        = $Snapshot.PowerShellEdition
                DotNetVersion            = ConvertTo-KeldorVersion -Value $Snapshot.DotNetVersion
                AzureResourceId          = $Snapshot.AzureResourceId
                AzureArcStatus           = $Snapshot.AzureArcStatus
                IsSuccessful             = $Snapshot.IsSuccessful
                ErrorCategory            = $Snapshot.ErrorCategory
                ErrorCode                = $Snapshot.ErrorCode
                ErrorMessage             = $Snapshot.ErrorMessage
                CollectedAt              = $Snapshot.CollectedAt
            }
            $result.PSObject.TypeNames.Insert(0, 'Keldor.SystemInfo')
            $result
        }
    }
}
