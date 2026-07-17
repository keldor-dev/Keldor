function Get-KeldorMacOSSystemSnapshot {
    [CmdletBinding()]
    param()

    $snapshot = New-KeldorSystemSnapshot -ComputerName ([Environment]::MachineName) -Platform 'macOS'
    $snapshot.Kernel.Is64BitOperatingSystem = [Environment]::Is64BitOperatingSystem

    try {
        $productName = Invoke-KeldorNativeCommand -FilePath sw_vers -ArgumentList '-productName'
        $productVersion = Invoke-KeldorNativeCommand -FilePath sw_vers -ArgumentList '-productVersion'
        $buildVersion = Invoke-KeldorNativeCommand -FilePath sw_vers -ArgumentList '-buildVersion'
        if ($productName.IsSuccessful) {
            $snapshot.OperatingSystem.Name = $productName.Output | Select-Object -First 1
        }
        $snapshot.OperatingSystem.Caption = $snapshot.OperatingSystem.Name
        if ($productVersion.IsSuccessful) {
            try {
                $snapshot.OperatingSystem.Version = [version]($productVersion.Output | Select-Object -First 1)
            } catch {
                $snapshot.OperatingSystem.Version = $null
            }
            $snapshot.OperatingSystem.VersionString = $productVersion.Output | Select-Object -First 1
        }
        if ($buildVersion.IsSuccessful) {
            $snapshot.OperatingSystem.BuildNumber = $buildVersion.Output | Select-Object -First 1
        }
        $snapshot.OperatingSystem.IsServer = $false
        $snapshot.OperatingSystem.IsDomainController = $false
        $snapshot.OperatingSystem.Source = 'sw_vers'
    } catch {
        Write-Verbose "Could not collect macOS product data: $($_.Exception.Message)"
    }

    try {
        $kernelName = Invoke-KeldorNativeCommand -FilePath uname -ArgumentList '-s'
        $kernelRelease = Invoke-KeldorNativeCommand -FilePath uname -ArgumentList '-r'
        $kernelVersion = Invoke-KeldorNativeCommand -FilePath uname -ArgumentList '-v'
        $architecture = Invoke-KeldorNativeCommand -FilePath uname -ArgumentList '-m'
        $hostName = Invoke-KeldorNativeCommand -FilePath uname -ArgumentList '-n'
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
        $snapshot.OperatingSystem.Architecture = $snapshot.Kernel.Architecture
        $snapshot.Hardware.Architecture = $snapshot.Kernel.Architecture
    } catch {
        Write-Verbose "Could not collect macOS kernel data: $($_.Exception.Message)"
    }

    try {
        $bootTimeResult = Invoke-KeldorNativeCommand -FilePath sysctl -ArgumentList @('-n', 'kern.boottime')
        $bootTimeText = $bootTimeResult.Output -join ' '
        if ($bootTimeResult.ExitCode -eq 0 -and $bootTimeText -match 'sec\s*=\s*(\d+)') {
            $lastBootTime = [datetimeoffset]::FromUnixTimeSeconds([long]$matches[1])
            $currentTime = [datetimeoffset]::Now
            $snapshot.Uptime.LastBootTime = $lastBootTime
            $snapshot.Uptime.CurrentTime = $currentTime
            $snapshot.Uptime.Uptime = $currentTime - $lastBootTime
            $snapshot.Uptime.Source = 'sysctl kern.boottime'
            $snapshot.OperatingSystem.LastBootTime = $lastBootTime
        }
    } catch {
        Write-Verbose "Could not collect macOS uptime: $($_.Exception.Message)"
    }

    if ($null -eq $snapshot.Uptime.Uptime) {
        try {
            $currentTime = [datetimeoffset]::Now
            $uptime = [timespan]::FromMilliseconds([Environment]::TickCount64)
            $snapshot.Uptime.LastBootTime = $currentTime.Subtract($uptime)
            $snapshot.Uptime.CurrentTime = $currentTime
            $snapshot.Uptime.Uptime = $uptime
            $snapshot.Uptime.Source = '.NET Environment.TickCount64'
            $snapshot.OperatingSystem.LastBootTime = $snapshot.Uptime.LastBootTime
        } catch {
            Write-Verbose "Could not use the monotonic macOS uptime fallback: $($_.Exception.Message)"
        }
    }

    try {
        $memory = Invoke-KeldorNativeCommand -FilePath sysctl -ArgumentList @('-n', 'hw.memsize')
        $physicalCores = Invoke-KeldorNativeCommand -FilePath sysctl -ArgumentList @('-n', 'hw.physicalcpu')
        $logicalCores = Invoke-KeldorNativeCommand -FilePath sysctl -ArgumentList @('-n', 'hw.logicalcpu')
        $model = Invoke-KeldorNativeCommand -FilePath sysctl -ArgumentList @('-n', 'hw.model')
        if ($memory.ExitCode -eq 0) {
            $snapshot.Hardware.MemoryBytes = [long]($memory.Output | Select-Object -First 1)
        }
        if ($physicalCores.ExitCode -eq 0) {
            $snapshot.Hardware.PhysicalCoreCount = [int]($physicalCores.Output | Select-Object -First 1)
        }
        if ($logicalCores.ExitCode -eq 0) {
            $snapshot.Hardware.LogicalProcessorCount = [int]($logicalCores.Output | Select-Object -First 1)
        }
        if ($model.ExitCode -eq 0) {
            $snapshot.Hardware.Model = $model.Output | Select-Object -First 1
        }
        if ($snapshot.Hardware.PhysicalCoreCount -or $snapshot.Hardware.LogicalProcessorCount) {
            $snapshot.Hardware.ProcessorCount = 1
        }
    } catch {
        Write-Verbose "Could not collect core macOS hardware data: $($_.Exception.Message)"
    }

    try {
        $hardwareProfile = Invoke-KeldorNativeCommand `
            -FilePath system_profiler `
            -ArgumentList @('SPHardwareDataType', '-detailLevel', 'mini')
        foreach ($line in @($hardwareProfile.Output | Where-Object { $hardwareProfile.IsSuccessful })) {
            if ($line -match '^\s*Model Name:\s*(.+)$') { $snapshot.Hardware.SystemType = $matches[1].Trim() }
            if ($line -match '^\s*Model Identifier:\s*(.+)$' -and !$snapshot.Hardware.Model) {
                $snapshot.Hardware.Model = $matches[1].Trim()
            }
            if ($line -match '^\s*(Chip|Processor Name):\s*(.+)$') { $snapshot.Hardware.ProcessorModel = $matches[2].Trim() }
            if ($line -match '^\s*Serial Number.*:\s*(.+)$') { $snapshot.Hardware.SerialNumber = $matches[1].Trim() }
            if ($line -match '^\s*Hardware UUID:\s*(.+)$') { $snapshot.Hardware.SystemUuid = $matches[1].Trim() }
            if ($line -match '^\s*Total Number of Cores:\s*(\d+)' -and !$snapshot.Hardware.PhysicalCoreCount) {
                $snapshot.Hardware.PhysicalCoreCount = [int]$matches[1]
                $snapshot.Hardware.LogicalProcessorCount = [int]$matches[1]
                $snapshot.Hardware.ProcessorCount = 1
            }
            if ($line -match '^\s*Memory:\s*([\d.]+)\s*(GB|MB)' -and !$snapshot.Hardware.MemoryBytes) {
                $memoryValue = [double]::Parse($matches[1], [Globalization.CultureInfo]::InvariantCulture)
                $snapshot.Hardware.MemoryBytes = if ($matches[2] -eq 'GB') {
                    [long]($memoryValue * 1GB)
                } else {
                    [long]($memoryValue * 1MB)
                }
            }
        }
    } catch {
        Write-Verbose "Could not collect the narrow macOS hardware profile: $($_.Exception.Message)"
    }

    if (!$snapshot.Hardware.ProcessorModel) {
        try {
            $processor = Invoke-KeldorNativeCommand -FilePath sysctl -ArgumentList @('-n', 'machdep.cpu.brand_string')
            if ($processor.IsSuccessful) {
                $snapshot.Hardware.ProcessorModel = $processor.Output | Select-Object -First 1
            }
        } catch {
            Write-Verbose "Could not determine the macOS processor model: $($_.Exception.Message)"
        }
    }

    $snapshot.Hardware.Manufacturer = 'Apple Inc.'
    $snapshot.Hardware.ProcessorManufacturer = if ($snapshot.Hardware.ProcessorModel -match 'Intel') {
        'Intel'
    } elseif ($snapshot.Hardware.ProcessorModel -match 'AMD') {
        'AMD'
    } elseif ($snapshot.Hardware.ProcessorModel) {
        'Apple Inc.'
    } else {
        $null
    }
    $snapshot.Hardware.FirmwareManufacturer = 'Apple Inc.'
    $snapshot.Hardware.Source = 'sysctl;system_profiler SPHardwareDataType'
    $virtualization = Resolve-KeldorVirtualization `
        -Manufacturer $snapshot.Hardware.Manufacturer `
        -Model $snapshot.Hardware.Model `
        -FirmwareManufacturer $snapshot.Hardware.FirmwareManufacturer
    $snapshot.Hardware.IsVirtualMachine = $virtualization.IsVirtualMachine
    $snapshot.Hardware.VirtualizationPlatform = $virtualization.VirtualizationPlatform

    $snapshot.Fqdn = $snapshot.Kernel.HostName
    $snapshot
}
