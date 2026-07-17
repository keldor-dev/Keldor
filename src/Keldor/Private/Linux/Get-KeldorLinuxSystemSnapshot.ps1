function Get-KeldorLinuxSystemSnapshot {
    [CmdletBinding()]
    param()

    $snapshot = New-KeldorSystemSnapshot -ComputerName ([Environment]::MachineName) -Platform 'Linux'
    $snapshot.Kernel.Is64BitOperatingSystem = [Environment]::Is64BitOperatingSystem

    $osReleasePath = $null
    $osReleaseResult = $null
    try {
        $osReleaseResult = Get-KeldorLinuxOsRelease
    } catch {
        Write-Verbose "Could not read Linux os-release data: $($_.Exception.Message)"
    }

    if ($osReleaseResult) {
        try {
            $osRelease = $osReleaseResult.Data
            $osReleasePath = $osReleaseResult.SourcePath
            $snapshot.LinuxDistribution.Name = $osRelease.NAME
            $snapshot.LinuxDistribution.Id = $osRelease.ID
            $snapshot.LinuxDistribution.IdLike = if ($osRelease.ID_LIKE) {
                [string[]]($osRelease.ID_LIKE -split '\s+' | Where-Object { $_ })
            } else {
                [string[]]@()
            }
            $snapshot.LinuxDistribution.PrettyName = $osRelease.PRETTY_NAME
            $snapshot.LinuxDistribution.Version = $osRelease.VERSION
            $snapshot.LinuxDistribution.VersionId = $osRelease.VERSION_ID
            $snapshot.LinuxDistribution.VersionCodename = $osRelease.VERSION_CODENAME
            $snapshot.LinuxDistribution.BuildId = $osRelease.BUILD_ID
            $snapshot.LinuxDistribution.Variant = $osRelease.VARIANT
            $snapshot.LinuxDistribution.VariantId = $osRelease.VARIANT_ID
            $snapshot.LinuxDistribution.HomeUrl = $osRelease.HOME_URL
            $snapshot.LinuxDistribution.SupportUrl = $osRelease.SUPPORT_URL
            $snapshot.LinuxDistribution.BugReportUrl = $osRelease.BUG_REPORT_URL
            $snapshot.LinuxDistribution.SourcePath = $osReleasePath
        } catch {
            Write-Verbose "Could not parse ${osReleasePath}: $($_.Exception.Message)"
        }
    }

    $unamePath = @('/usr/bin/uname', '/bin/uname') | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
        Select-Object -First 1
    if ($unamePath) {
        try {
            $kernelName = Invoke-KeldorNativeCommand -FilePath $unamePath -ArgumentList '-s'
            $kernelRelease = Invoke-KeldorNativeCommand -FilePath $unamePath -ArgumentList '-r'
            $kernelVersion = Invoke-KeldorNativeCommand -FilePath $unamePath -ArgumentList '-v'
            $architecture = Invoke-KeldorNativeCommand -FilePath $unamePath -ArgumentList '-m'
            $hostName = Invoke-KeldorNativeCommand -FilePath $unamePath -ArgumentList '-n'

            if ($kernelName.IsSuccessful) {
                $snapshot.Kernel.KernelName = $kernelName.Output | Select-Object -First 1
            }
            if ($kernelRelease.IsSuccessful) {
                $snapshot.Kernel.KernelRelease = $kernelRelease.Output | Select-Object -First 1
            }
            if ($kernelVersion.IsSuccessful) {
                $snapshot.Kernel.KernelVersion = $kernelVersion.Output | Select-Object -First 1
            }
            if ($architecture.IsSuccessful) {
                $snapshot.Kernel.Architecture = $architecture.Output | Select-Object -First 1
            }
            if ($hostName.IsSuccessful) {
                $snapshot.Kernel.HostName = $hostName.Output | Select-Object -First 1
            }
            if ($kernelName.IsSuccessful -or $kernelRelease.IsSuccessful) {
                $snapshot.Kernel.Source = 'uname'
            }
            $snapshot.Hardware.Architecture = $snapshot.Kernel.Architecture
        } catch {
            Write-Verbose "Could not collect Linux kernel data: $($_.Exception.Message)"
        }
    }

    if (Test-Path -LiteralPath '/proc/sys/kernel/random/boot_id' -PathType Leaf) {
        try {
            $snapshot.Kernel.BootId = (Get-Content -LiteralPath '/proc/sys/kernel/random/boot_id' -Raw -ErrorAction Stop).Trim()
        } catch {
            Write-Verbose "Could not read the Linux boot ID: $($_.Exception.Message)"
        }
    }

    $currentTime = [datetimeoffset]::UtcNow
    if (Test-Path -LiteralPath '/proc/uptime' -PathType Leaf) {
        try {
            $uptimeText = (Get-Content -LiteralPath '/proc/uptime' -Raw -ErrorAction Stop).Trim().Split(' ')[0]
            $uptimeSeconds = 0.0
            if ([double]::TryParse(
                    $uptimeText,
                    [Globalization.NumberStyles]::Float,
                    [Globalization.CultureInfo]::InvariantCulture,
                    [ref]$uptimeSeconds
                )) {
                $uptime = [timespan]::FromSeconds($uptimeSeconds)
                $snapshot.Uptime.CurrentTime = $currentTime
                $snapshot.Uptime.Uptime = $uptime
                $snapshot.Uptime.LastBootTime = $currentTime.Subtract($uptime)
                $snapshot.Uptime.Source = '/proc/uptime'
            }
        } catch {
            Write-Verbose "Could not collect Linux uptime: $($_.Exception.Message)"
        }
    }

    $dmiProperties = @{
        Manufacturer         = '/sys/class/dmi/id/sys_vendor'
        Model                = '/sys/class/dmi/id/product_name'
        SerialNumber         = '/sys/class/dmi/id/product_serial'
        SystemUuid           = '/sys/class/dmi/id/product_uuid'
        AssetTag             = '/sys/class/dmi/id/chassis_asset_tag'
        ChassisType          = '/sys/class/dmi/id/chassis_type'
        FirmwareManufacturer = '/sys/class/dmi/id/bios_vendor'
        FirmwareVersion      = '/sys/class/dmi/id/bios_version'
        FirmwareReleaseDate  = '/sys/class/dmi/id/bios_date'
    }
    foreach ($propertyName in $dmiProperties.Keys) {
        $path = $dmiProperties[$propertyName]
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            try {
                $value = (Get-Content -LiteralPath $path -Raw -ErrorAction Stop).Trim()
                if ($value) {
                    $snapshot.Hardware.$propertyName = $value
                }
            } catch {
                Write-Verbose "Could not read ${path}: $($_.Exception.Message)"
            }
        }
    }

    if (Test-Path -LiteralPath '/proc/cpuinfo' -PathType Leaf) {
        try {
            $cpuInfo = Get-Content -LiteralPath '/proc/cpuinfo' -ErrorAction Stop
            $processorLines = @($cpuInfo | Where-Object { $_ -match '^processor\s*:' })
            $modelLine = $cpuInfo | Where-Object { $_ -match '^(model name|Hardware|Processor)\s*:' } |
                Select-Object -First 1
            $vendorLine = $cpuInfo | Where-Object { $_ -match '^(vendor_id|CPU implementer)\s*:' } |
                Select-Object -First 1
            $corePairs = @($cpuInfo | Where-Object { $_ -match '^(physical id|core id)\s*:' })

            $snapshot.Hardware.LogicalProcessorCount = $processorLines.Count
            if ($modelLine) { $snapshot.Hardware.ProcessorModel = ($modelLine -split ':', 2)[1].Trim() }
            if ($vendorLine) { $snapshot.Hardware.ProcessorManufacturer = ($vendorLine -split ':', 2)[1].Trim() }

            if ($corePairs.Count -gt 0) {
                $physicalIds = @($cpuInfo | Where-Object { $_ -match '^physical id\s*:' })
                $coreIds = @($cpuInfo | Where-Object { $_ -match '^core id\s*:' })
                $pairs = for ($index = 0; $index -lt [math]::Min($physicalIds.Count, $coreIds.Count); $index++) {
                    "$(($physicalIds[$index] -split ':', 2)[1].Trim()):$(($coreIds[$index] -split ':', 2)[1].Trim())"
                }
                $snapshot.Hardware.PhysicalCoreCount = @($pairs | Sort-Object -Unique).Count
                $snapshot.Hardware.ProcessorCount = @(
                    $physicalIds |
                        ForEach-Object { ($_ -split ':', 2)[1].Trim() } |
                        Sort-Object -Unique
                ).Count
            }
        } catch {
            Write-Verbose "Could not collect Linux processor data: $($_.Exception.Message)"
        }
    }

    if (Test-Path -LiteralPath '/proc/meminfo' -PathType Leaf) {
        try {
            $memoryLine = Get-Content -LiteralPath '/proc/meminfo' -ErrorAction Stop |
                Where-Object { $_ -match '^MemTotal:\s+(\d+)\s+kB' } |
                Select-Object -First 1
            if ($memoryLine -match '^MemTotal:\s+(\d+)\s+kB') {
                $snapshot.Hardware.MemoryBytes = [long]$matches[1] * 1KB
            }
        } catch {
            Write-Verbose "Could not collect Linux memory data: $($_.Exception.Message)"
        }
    }

    if (!$snapshot.Hardware.ProcessorCount -and $snapshot.Hardware.LogicalProcessorCount) {
        $snapshot.Hardware.ProcessorCount = 1
    }
    $snapshot.Hardware.Source = 'sysfs;/proc'
    $virtualization = Resolve-KeldorVirtualization `
        -Manufacturer $snapshot.Hardware.Manufacturer `
        -Model $snapshot.Hardware.Model `
        -FirmwareManufacturer $snapshot.Hardware.FirmwareManufacturer
    $snapshot.Hardware.IsVirtualMachine = $virtualization.IsVirtualMachine
    $snapshot.Hardware.VirtualizationPlatform = $virtualization.VirtualizationPlatform

    $distributionName = $snapshot.LinuxDistribution.PrettyName
    if (!$distributionName) { $distributionName = $snapshot.LinuxDistribution.Name }
    $snapshot.OperatingSystem.Name = $distributionName
    $snapshot.OperatingSystem.Caption = $distributionName
    $snapshot.OperatingSystem.Edition = $snapshot.LinuxDistribution.Variant
    if ($snapshot.LinuxDistribution.VersionId) {
        try {
            $snapshot.OperatingSystem.Version = [version]$snapshot.LinuxDistribution.VersionId
        } catch {
            $snapshot.OperatingSystem.Version = $null
        }
    }
    $snapshot.OperatingSystem.VersionString = $snapshot.LinuxDistribution.Version
    $snapshot.OperatingSystem.Architecture = $snapshot.Kernel.Architecture
    $snapshot.OperatingSystem.IsServer = $null
    $snapshot.OperatingSystem.IsDomainController = $null
    $snapshot.OperatingSystem.LastBootTime = $snapshot.Uptime.LastBootTime
    $snapshot.OperatingSystem.Source = if ($osReleasePath) { $osReleasePath } else { 'uname' }

    $snapshot.Fqdn = $snapshot.Kernel.HostName
    $snapshot
}
