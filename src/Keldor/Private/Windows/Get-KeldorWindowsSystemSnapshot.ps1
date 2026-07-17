function Get-KeldorWindowsSystemSnapshot {
    [CmdletBinding()]
    param()

    $snapshot = New-KeldorSystemSnapshot -ComputerName ([Environment]::MachineName) -Platform 'Windows'
    $source = if (Get-Command -Name Get-CimInstance -ErrorAction SilentlyContinue) { 'CIM' } else { 'WMI' }

    $operatingSystem = Get-KeldorWindowsManagementObject -ClassName Win32_OperatingSystem
    $computerSystem = Get-KeldorWindowsManagementObject -ClassName Win32_ComputerSystem
    $computerSystemProduct = Get-KeldorWindowsManagementObject -ClassName Win32_ComputerSystemProduct
    $bios = Get-KeldorWindowsManagementObject -ClassName Win32_BIOS
    $processors = @(Get-KeldorWindowsManagementObject -ClassName Win32_Processor)
    $enclosure = Get-KeldorWindowsManagementObject -ClassName Win32_SystemEnclosure

    $registry = $null
    try {
        $registry = Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction Stop
    } catch {
        Write-Verbose "Could not read Windows product registry data: $($_.Exception.Message)"
    }

    $lastBootTime = ConvertTo-KeldorWindowsDateTime -Value $operatingSystem.LastBootUpTime
    $installDate = ConvertTo-KeldorWindowsDateTime -Value $operatingSystem.InstallDate
    $currentTime = [datetimeoffset]::Now
    $uptime = if ($lastBootTime) { $currentTime - [datetimeoffset]$lastBootTime } else { $null }
    $productType = if ($null -ne $operatingSystem.ProductType) { [int]$operatingSystem.ProductType } else { $null }

    $snapshot.OperatingSystem.Name = [string]$operatingSystem.Caption
    $snapshot.OperatingSystem.Caption = [string]$operatingSystem.Caption
    $snapshot.OperatingSystem.Edition = if ($registry) { $registry.EditionID } else { $null }
    try { $snapshot.OperatingSystem.Version = [version]$operatingSystem.Version } catch {
        $snapshot.OperatingSystem.Version = $operatingSystem.Version
    }
    $snapshot.OperatingSystem.VersionString = [string]$operatingSystem.Version
    $snapshot.OperatingSystem.BuildNumber = [string]$operatingSystem.BuildNumber
    $snapshot.OperatingSystem.Architecture = [string]$operatingSystem.OSArchitecture
    $snapshot.OperatingSystem.InstallationType = if ($registry) { $registry.InstallationType } else { $null }
    $snapshot.OperatingSystem.IsServer = if ($null -ne $productType) { $productType -ne 1 } else { $null }
    $snapshot.OperatingSystem.IsDomainController = if ($null -ne $productType) { $productType -eq 2 } else { $null }
    $snapshot.OperatingSystem.ProductType = $productType
    $snapshot.OperatingSystem.ProductId = if ($registry) { $registry.ProductId } else { $null }
    $snapshot.OperatingSystem.InstallDate = $installDate
    $snapshot.OperatingSystem.LastBootTime = $lastBootTime
    $snapshot.OperatingSystem.Source = $source

    $domainName = $null
    try {
        $domainName = [Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().DomainName
    } catch {
        Write-Verbose "Could not determine the Windows DNS domain: $($_.Exception.Message)"
    }
    $snapshot.Kernel.KernelName = 'Windows NT'
    $snapshot.Kernel.KernelVersion = $snapshot.OperatingSystem.Version
    $snapshot.Kernel.KernelRelease = $snapshot.OperatingSystem.BuildNumber
    $snapshot.Kernel.Architecture = $snapshot.OperatingSystem.Architecture
    $snapshot.Kernel.HostName = [Environment]::MachineName
    $snapshot.Kernel.DomainName = $domainName
    $snapshot.Kernel.Is64BitOperatingSystem = [Environment]::Is64BitOperatingSystem
    $snapshot.Kernel.Source = '.NET;Win32_OperatingSystem'

    $snapshot.Uptime.LastBootTime = $lastBootTime
    $snapshot.Uptime.CurrentTime = $currentTime
    $snapshot.Uptime.Uptime = $uptime
    $snapshot.Uptime.Source = $source

    $physicalCoreCount = ($processors | Measure-Object -Property NumberOfCores -Sum).Sum
    $logicalProcessorCount = ($processors | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum
    $processor = $processors | Select-Object -First 1
    $chassisType = $enclosure.ChassisTypes | Select-Object -First 1

    $snapshot.Hardware.Manufacturer = [string]$computerSystem.Manufacturer
    $snapshot.Hardware.Model = [string]$computerSystem.Model
    $snapshot.Hardware.SerialNumber = [string]$bios.SerialNumber
    $snapshot.Hardware.SystemUuid = [string]$computerSystemProduct.UUID
    $snapshot.Hardware.AssetTag = [string]$enclosure.SMBIOSAssetTag
    $snapshot.Hardware.ChassisType = if ($null -ne $chassisType) { [string]$chassisType } else { $null }
    $snapshot.Hardware.SystemType = [string]$computerSystem.SystemType
    $snapshot.Hardware.Architecture = $snapshot.OperatingSystem.Architecture
    $snapshot.Hardware.ProcessorManufacturer = [string]$processor.Manufacturer
    $snapshot.Hardware.ProcessorModel = [string]$processor.Name
    $snapshot.Hardware.ProcessorCount = if ($null -ne $computerSystem.NumberOfProcessors) {
        [int]$computerSystem.NumberOfProcessors
    } else {
        $processors.Count
    }
    $snapshot.Hardware.PhysicalCoreCount = if ($null -ne $physicalCoreCount) { [int]$physicalCoreCount } else { $null }
    $snapshot.Hardware.LogicalProcessorCount = if ($null -ne $logicalProcessorCount) {
        [int]$logicalProcessorCount
    } else {
        $null
    }
    $snapshot.Hardware.MemoryBytes = if ($null -ne $computerSystem.TotalPhysicalMemory) {
        [long]$computerSystem.TotalPhysicalMemory
    } else {
        $null
    }
    $snapshot.Hardware.FirmwareManufacturer = [string]$bios.Manufacturer
    $snapshot.Hardware.FirmwareVersion = [string]$bios.SMBIOSBIOSVersion
    $snapshot.Hardware.FirmwareReleaseDate = ConvertTo-KeldorWindowsDateTime -Value $bios.ReleaseDate
    $snapshot.Hardware.Source = $source

    $virtualization = Resolve-KeldorVirtualization `
        -Manufacturer $snapshot.Hardware.Manufacturer `
        -Model $snapshot.Hardware.Model `
        -FirmwareManufacturer $snapshot.Hardware.FirmwareManufacturer
    $snapshot.Hardware.IsVirtualMachine = $virtualization.IsVirtualMachine
    $snapshot.Hardware.VirtualizationPlatform = $virtualization.VirtualizationPlatform

    if ($domainName) {
        $snapshot.Fqdn = "$([Environment]::MachineName).${domainName}"
    } else {
        $snapshot.Fqdn = [Environment]::MachineName
    }

    $snapshot
}
