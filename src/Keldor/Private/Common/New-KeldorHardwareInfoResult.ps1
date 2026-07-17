function New-KeldorHardwareInfoResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Snapshot
    )

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
