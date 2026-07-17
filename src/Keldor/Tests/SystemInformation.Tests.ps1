$systemInformationModuleRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $systemInformationModuleRoot 'Keldor.psd1') -Force

Describe 'Keldor system information commands' {
    BeforeAll {
        $script:ModuleRoot = Split-Path -Parent $PSScriptRoot
        $script:RepositoryRoot = Split-Path -Parent (Split-Path -Parent $script:ModuleRoot)
        Import-Module (Join-Path $script:ModuleRoot 'Keldor.psd1') -Force
        $script:CommandNames = @(
            'Get-KeldorSystemInfo'
            'Get-KeldorOperatingSystem'
            'Get-KeldorLinuxDistribution'
            'Get-KeldorKernel'
            'Get-KeldorUptime'
            'Get-KeldorHardwareInfo'
        )
    }

    It 'exports every system information command' {
        foreach ($commandName in $script:CommandNames) {
            $command = Get-Command -Name $commandName -Module Keldor
            $command.CommandType | Should -Be 'Function'
        }
    }

    It 'uses consistent Local, ComputerName, and PSSession parameter sets' {
        foreach ($commandName in $script:CommandNames) {
            $command = Get-Command -Name $commandName -Module Keldor
            @($command.ParameterSets.Name) | Should -Contain 'Local'
            @($command.ParameterSets.Name) | Should -Contain 'ComputerName'
            @($command.ParameterSets.Name) | Should -Contain 'PSSession'
            $command.ParameterSets | Where-Object Name -EQ 'Local' | Select-Object -ExpandProperty IsDefault |
                Should -BeTrue
            $command.Parameters.ComputerName.Attributes.ValueFromPipeline | Should -Contain $true
            $command.Parameters.ComputerName.Attributes.ValueFromPipelineByPropertyName | Should -Contain $true
            $command.Parameters.PSSession.Attributes.ValueFromPipeline | Should -Contain $true
        }
    }

    It 'provides complete help and canonical links' {
        foreach ($commandName in $script:CommandNames) {
            $help = Get-Help -Name $commandName -Full
            $help.Synopsis | Should -Not -BeNullOrEmpty
            $help.Description.Text | Should -Not -BeNullOrEmpty
            @($help.Examples.Example).Count | Should -BeGreaterThan 0
            $help.InputTypes.InputType.Type.Name | Should -Not -BeNullOrEmpty
            $help.ReturnValues.ReturnValue.Type.Name | Should -Match '^Keldor\.'
            $help.AlertSet.Alert.Text | Should -Not -BeNullOrEmpty
            $help.RelatedLinks.NavigationLink.Uri | Should -Contain "https://docs.keldor.dev/powershell/keldor/$commandName"
        }
    }

    It 'keeps public implementations read-only and free of presentation commands' {
        foreach ($commandName in $script:CommandNames) {
            $path = Join-Path $script:ModuleRoot "Public/Common/${commandName}.ps1"
            $tokens = $null
            $errors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors)
            $errors | Should -BeNullOrEmpty
            $commands = $ast.FindAll(
                {
                    param($node)
                    $node -is [System.Management.Automation.Language.CommandAst]
                },
                $true
            ) | ForEach-Object { $_.GetCommandName() }

            @($commands) | Should -Not -Contain 'Write-Host'
            @($commands) | Should -Not -Contain 'Format-Table'
            @($commands) | Should -Not -Contain 'Format-List'
            @($commands) | Should -Not -Contain 'Out-String'
            $ast.Extent.Text | Should -Not -Match 'SupportsShouldProcess\s*=\s*\$true'
        }
    }

    InModuleScope Keldor {
        It 'normalizes Windows, Linux, and macOS operating-system fixtures' -ForEach @(
            @{ Platform = 'Windows'; Name = 'Windows Server'; Version = [version]'10.0.20348' }
            @{ Platform = 'Linux'; Name = 'Example Linux'; Version = [version]'24.4' }
            @{ Platform = 'macOS'; Name = 'macOS'; Version = [version]'15.5' }
        ) {
            $snapshot = New-KeldorSystemSnapshot -ComputerName 'fixture01' -Platform $Platform
            $snapshot.OperatingSystem.Name = $Name
            $snapshot.OperatingSystem.Version = $Version
            $snapshot.OperatingSystem.Caption = $Name
            $result = New-KeldorOperatingSystemResult -Snapshot $snapshot

            $result.Platform | Should -Be $Platform
            $result.Name | Should -Be $Name
            $result.Version | Should -Be $Version
            $result.PSObject.TypeNames[0] | Should -Be 'Keldor.OperatingSystem'
            $result.Edition | Should -BeNullOrEmpty
        }

        It 'preserves stable operating-system property order' {
            $snapshot = New-KeldorSystemSnapshot -ComputerName 'fixture01' -Platform 'Windows'
            $result = New-KeldorOperatingSystemResult -Snapshot $snapshot
            @($result.PSObject.Properties.Name) | Should -Be @(
                'ComputerName', 'Platform', 'Name', 'Caption', 'Edition', 'Version', 'VersionString', 'BuildNumber',
                'Architecture', 'InstallationType', 'IsServer', 'IsDomainController', 'ProductType', 'ProductId',
                'InstallDate', 'LastBootTime', 'Source', 'IsSuccessful', 'ErrorCategory', 'ErrorCode', 'ErrorMessage',
                'CollectedAt'
            )
        }

        It 'normalizes Darwin as a macOS kernel fixture' {
            $snapshot = New-KeldorSystemSnapshot -ComputerName 'mac01' -Platform 'macOS'
            $snapshot.Kernel.KernelName = 'Darwin'
            $snapshot.Kernel.KernelRelease = '24.5.0'
            $result = New-KeldorKernelResult -Snapshot $snapshot

            $result.Platform | Should -Be 'macOS'
            $result.KernelName | Should -Be 'Darwin'
            $result.PSObject.TypeNames[0] | Should -Be 'Keldor.Kernel'
        }

        It 'preserves native uptime types and numeric totals' {
            $snapshot = New-KeldorSystemSnapshot -ComputerName 'fixture01' -Platform 'Linux'
            $snapshot.Uptime.CurrentTime = [datetimeoffset]::UtcNow
            $snapshot.Uptime.Uptime = [timespan]::FromHours(49.5)
            $snapshot.Uptime.LastBootTime = $snapshot.Uptime.CurrentTime.Subtract($snapshot.Uptime.Uptime)
            $result = New-KeldorUptimeResult -Snapshot $snapshot

            $result.Uptime | Should -BeOfType ([timespan])
            $result.LastBootTime | Should -BeOfType ([datetimeoffset])
            $result.TotalDays | Should -BeOfType ([double])
            $result.TotalHours | Should -Be 49.5
            $result.PSObject.TypeNames[0] | Should -Be 'Keldor.Uptime'
        }

        It 'normalizes hardware fixtures and native memory types' -ForEach @(
            @{ Platform = 'Windows'; Manufacturer = 'Dell Inc.'; Model = 'PowerEdge'; Expected = $null }
            @{ Platform = 'Windows'; Manufacturer = 'Microsoft Corporation'; Model = 'Virtual Machine'; Expected = 'Hyper-V' }
            @{ Platform = 'Windows'; Manufacturer = 'VMware, Inc.'; Model = 'VMware Virtual Platform'; Expected = 'VMware' }
            @{ Platform = 'Windows'; Manufacturer = 'Nutanix'; Model = 'AHV'; Expected = 'Nutanix AHV' }
            @{ Platform = 'Linux'; Manufacturer = 'QEMU'; Model = 'Standard PC (KVM)'; Expected = 'KVM' }
            @{ Platform = 'macOS'; Manufacturer = 'Apple Inc.'; Model = 'Mac15,9'; Expected = $null }
            @{ Platform = 'macOS'; Manufacturer = 'Apple Inc.'; Model = 'VirtualMac2,1'; Expected = 'Apple Virtualization' }
        ) {
            $snapshot = New-KeldorSystemSnapshot -ComputerName 'hardware01' -Platform $Platform
            $snapshot.Hardware.Manufacturer = $Manufacturer
            $snapshot.Hardware.Model = $Model
            $snapshot.Hardware.MemoryBytes = [long](16GB)
            $virtualization = Resolve-KeldorVirtualization -Manufacturer $Manufacturer -Model $Model
            $snapshot.Hardware.IsVirtualMachine = $virtualization.IsVirtualMachine
            $snapshot.Hardware.VirtualizationPlatform = $virtualization.VirtualizationPlatform
            $result = New-KeldorHardwareInfoResult -Snapshot $snapshot

            $result.MemoryBytes | Should -BeOfType ([long])
            $result.MemoryGB | Should -BeOfType ([double])
            $result.VirtualizationPlatform | Should -Be $Expected
            if ($null -eq $Expected) { $result.IsVirtualMachine | Should -BeNullOrEmpty }
            $result.PSObject.TypeNames[0] | Should -Be 'Keldor.HardwareInfo'
        }

        It 'preserves Apple Silicon and Intel Mac processor fixtures' -ForEach @(
            @{ Model = 'Apple M3 Max'; Manufacturer = 'Apple Inc.'; Architecture = 'arm64' }
            @{ Model = 'Intel(R) Core(TM) i7'; Manufacturer = 'Intel'; Architecture = 'x86_64' }
        ) {
            $snapshot = New-KeldorSystemSnapshot -ComputerName 'mac-fixture' -Platform 'macOS'
            $snapshot.Hardware.ProcessorModel = $Model
            $snapshot.Hardware.ProcessorManufacturer = $Manufacturer
            $snapshot.Hardware.Architecture = $Architecture
            $result = New-KeldorHardwareInfoResult -Snapshot $snapshot

            $result.ProcessorModel | Should -Be $Model
            $result.ProcessorManufacturer | Should -Be $Manufacturer
            $result.Architecture | Should -Be $Architecture
        }

        It 'allows missing DMI and serial information without failing hardware inventory' {
            $snapshot = New-KeldorSystemSnapshot -ComputerName 'arm-board' -Platform 'Linux'
            $snapshot.Hardware.Architecture = 'aarch64'
            $result = New-KeldorHardwareInfoResult -Snapshot $snapshot

            $result.IsSuccessful | Should -BeTrue
            $result.SerialNumber | Should -BeNullOrEmpty
            $result.IsVirtualMachine | Should -BeNullOrEmpty
        }

        It 'builds aggregate inventory from one shared snapshot' {
            Mock Get-KeldorSystemSnapshot {
                $snapshot = New-KeldorSystemSnapshot -ComputerName 'system01' -Platform 'Linux'
                $snapshot.OperatingSystem.Name = 'Example Linux'
                $snapshot.LinuxDistribution.PrettyName = 'Example Linux 1'
                $snapshot.Hardware.Model = 'Fixture Model'
                $snapshot.Uptime.Uptime = [timespan]::FromDays(2)
                $snapshot
            }

            $result = Get-KeldorSystemInfo

            Should -Invoke Get-KeldorSystemSnapshot -Times 1 -Exactly
            $result.OperatingSystem | Should -Be 'Example Linux'
            $result.LinuxDistribution | Should -Be 'Example Linux 1'
            $result.Model | Should -Be 'Fixture Model'
            $result.Uptime | Should -BeOfType ([timespan])
            $result.PSObject.TypeNames[0] | Should -Be 'Keldor.SystemInfo'
        }

        It 'returns partial inventory when optional data is missing' {
            Mock Get-KeldorSystemSnapshot {
                $snapshot = New-KeldorSystemSnapshot -ComputerName 'partial01' -Platform 'Windows'
                $snapshot.OperatingSystem.Name = 'Windows'
                $snapshot
            }

            $result = Get-KeldorSystemInfo

            $result.IsSuccessful | Should -BeTrue
            $result.OperatingSystem | Should -Be 'Windows'
            $result.SerialNumber | Should -BeNullOrEmpty
            $result.LinuxDistribution | Should -BeNullOrEmpty
            $result.AzureResourceId | Should -BeNullOrEmpty
        }

        It 'returns a stable failure object when target identification fails' {
            $snapshot = New-KeldorSystemSnapshot `
                -ComputerName 'failed01' `
                -Platform $null `
                -IsSuccessful $false `
                -ErrorCategory 'ConnectionError' `
                -ErrorCode 'Keldor.TestFailure' `
                -ErrorMessage 'Fixture failure.'
            $result = New-KeldorSystemInfoResult -Snapshot $snapshot

            $result.ComputerName | Should -Be 'failed01'
            $result.IsSuccessful | Should -BeFalse
            $result.ErrorCode | Should -Be 'Keldor.TestFailure'
            $result.PSObject.TypeNames[0] | Should -Be 'Keldor.SystemInfo'
        }

        It 'keeps successful pipeline results when another target fails' {
            Mock Invoke-KeldorInventoryCollection {
                foreach ($target in $ComputerName) {
                    $snapshot = New-KeldorSystemSnapshot `
                        -ComputerName $target `
                        -Platform $(if ($target -eq 'bad') { $null } else { 'Linux' }) `
                        -IsSuccessful ($target -ne 'bad') `
                        -ErrorMessage $(if ($target -eq 'bad') { 'Fixture failure.' } else { $null })
                    New-KeldorSystemInfoResult -Snapshot $snapshot
                }
            }

            $results = @('good01', 'bad', 'good02') | Get-KeldorSystemInfo

            $results.Count | Should -Be 3
            ($results | Where-Object ComputerName -EQ 'good01').IsSuccessful | Should -BeTrue
            ($results | Where-Object ComputerName -EQ 'bad').IsSuccessful | Should -BeFalse
            ($results | Where-Object ComputerName -EQ 'good02').IsSuccessful | Should -BeTrue
        }
    }
}

Describe 'Linux os-release parser' {
    BeforeAll {
        $moduleRoot = Split-Path -Parent $PSScriptRoot
        . (Join-Path $moduleRoot 'Private/Linux/ConvertFrom-KeldorOsRelease.ps1')
        . (Join-Path $moduleRoot 'Private/Linux/Get-KeldorLinuxOsRelease.ps1')
    }

    It 'parses quoted, unquoted, empty, escaped, duplicate, and structured ID_LIKE values as data' {
        $content = @'
# comment
NAME="Example Linux"
ID=example
ID_LIKE="debian ubuntu"
VERSION_ID="1.0"
EMPTY=
PRETTY_NAME="Example \"Linux\" \\ Stable"
NAME="Example Linux Final"
'@
        $result = ConvertFrom-KeldorOsRelease -Content $content

        $result.NAME | Should -Be 'Example Linux Final'
        $result.ID | Should -Be 'example'
        [string[]]($result.ID_LIKE -split '\s+') | Should -Be @('debian', 'ubuntu')
        $result.EMPTY | Should -Be ''
        $result.PRETTY_NAME | Should -Be 'Example "Linux" \ Stable'
    }

    It 'prefers the first existing os-release path and falls back to the second' {
        $primary = Join-Path $TestDrive 'etc-os-release'
        $fallback = Join-Path $TestDrive 'usr-lib-os-release'
        Set-Content -LiteralPath $primary -Value 'ID=primary'
        Set-Content -LiteralPath $fallback -Value 'ID=fallback'

        $preferred = Get-KeldorLinuxOsRelease -Path @($primary, $fallback)
        $preferred.Data.ID | Should -Be 'primary'
        $preferred.SourcePath | Should -Be $primary

        Remove-Item -LiteralPath $primary
        $fallbackResult = Get-KeldorLinuxOsRelease -Path @($primary, $fallback)
        $fallbackResult.Data.ID | Should -Be 'fallback'
        $fallbackResult.SourcePath | Should -Be $fallback
    }

    It 'does not execute malicious-looking os-release content' {
        $marker = Join-Path $TestDrive 'must-not-exist'
        $content = 'NAME="$(Set-Content -LiteralPath ''' + $marker + ''' -Value pwned)"'

        $result = ConvertFrom-KeldorOsRelease -Content $content

        $result.NAME | Should -Match '^\$\(Set-Content'
        Test-Path -LiteralPath $marker | Should -BeFalse
    }
}

Describe 'Legacy system information compatibility wrappers' {
    BeforeAll {
        $moduleRoot = Split-Path -Parent $PSScriptRoot
        if (!(Get-Command -Name Test-ResponseTime -ErrorAction SilentlyContinue)) {
            function Test-ResponseTime { param([string[]]$RemoteAddress) }
        }
        . (Join-Path $moduleRoot 'Public/Windows/Get-UpTime.ps1')
        . (Join-Path $moduleRoot 'Public/Windows/Get-SerialNumber.ps1')
        . (Join-Path $moduleRoot 'Public/Windows/Get-ComputerModel.ps1')
        . (Join-Path $moduleRoot 'Public/Windows/Test-Online.ps1')
    }

    It 'delegates Get-UpTime to Get-KeldorUptime and preserves historical properties' {
        Mock Get-KeldorUptime {
            [pscustomobject]@{
                ComputerName = 'legacy01'
                LastBootTime = [datetime]::Now.AddDays(-1)
                Uptime       = [timespan]::FromHours(25)
                TotalHours   = 25.0
                IsSuccessful = $true
            }
        }

        $result = Get-Uptime
        Should -Invoke Get-KeldorUptime -Times 1
        @($result.PSObject.Properties.Name) | Should -Be @(
            'ComputerName', 'LastBoot', 'Total', 'Days', 'Hours', 'Minutes', 'Seconds'
        )
    }

    It 'delegates Get-SerialNumber and Get-ComputerModel to Get-KeldorHardwareInfo' {
        Mock Get-KeldorHardwareInfo {
            [pscustomobject]@{
                ComputerName     = 'legacy01'
                Manufacturer     = 'Example'
                Model            = 'Model 1'
                SerialNumber     = 'SERIAL1'
                SystemType       = 'Desktop'
                IsVirtualMachine = $null
                IsSuccessful     = $true
            }
        }

        $serial = Get-SerialNumber
        $model = Get-ComputerModel
        Should -Invoke Get-KeldorHardwareInfo -Times 2
        @($serial.PSObject.Properties.Name) | Should -Be @('ComputerName', 'SerialNumber')
        @($model.PSObject.Properties.Name) | Should -Be @(
            'ComputerName', 'DomainRole', 'Manufacturer', 'Model', 'PorV', 'Type'
        )
    }

    It 'delegates Test-Online ICMP behavior to Test-ResponseTime' {
        Mock Test-ResponseTime { [pscustomobject]@{ TestAddress = 'legacy01'; ResponseTime = 1 } }

        $result = Test-Online -ComputerName 'legacy01'

        Should -Invoke Test-ResponseTime -Times 1 -ParameterFilter { $RemoteAddress -eq 'legacy01' }
        $result.Name | Should -Be 'legacy01'
        $result.Status | Should -Be 'Online'
    }

    It 'contains no duplicate legacy discovery implementation' {
        $moduleRoot = Split-Path -Parent $PSScriptRoot
        foreach ($commandName in @('Get-UpTime', 'Get-SerialNumber', 'Get-ComputerModel')) {
            $content = Get-Content -LiteralPath (Join-Path $moduleRoot "Public/Windows/${commandName}.ps1") -Raw
            $content | Should -Not -Match 'Get-WmiObject|Get-CimInstance|Win32_'
        }
        $onlineContent = Get-Content -LiteralPath (Join-Path $moduleRoot 'Public/Windows/Test-Online.ps1') -Raw
        $onlineContent | Should -Not -Match '\bTest-Connection\b'
    }
}
