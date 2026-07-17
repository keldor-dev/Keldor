function New-KeldorSystemInfoResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Snapshot
    )

    $operatingSystem = New-KeldorOperatingSystemResult -Snapshot $Snapshot
    $kernel = New-KeldorKernelResult -Snapshot $Snapshot
    $uptime = New-KeldorUptimeResult -Snapshot $Snapshot
    $hardware = New-KeldorHardwareInfoResult -Snapshot $Snapshot
    $distribution = if ($Snapshot.Platform -eq 'Linux') {
        New-KeldorLinuxDistributionResult -Snapshot $Snapshot
    } else {
        $null
    }

    $result = [pscustomobject][ordered]@{
        ComputerName             = $Snapshot.ComputerName
        Fqdn                     = $Snapshot.Fqdn
        Platform                 = $Snapshot.Platform
        OperatingSystem          = $operatingSystem.Name
        OperatingSystemCaption   = $operatingSystem.Caption
        OperatingSystemEdition   = $operatingSystem.Edition
        OperatingSystemVersion   = $operatingSystem.Version
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
        MemoryBytes              = $hardware.MemoryBytes
        MemoryGB                 = $hardware.MemoryGB
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
