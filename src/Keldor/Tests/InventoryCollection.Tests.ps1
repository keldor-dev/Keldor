Import-Module (Join-Path (Split-Path -Parent $PSScriptRoot) 'Keldor.psd1') -Force

BeforeAll {
    Import-Module (Join-Path (Split-Path -Parent $PSScriptRoot) 'Keldor.psd1') -Force
}

Describe 'Inventory collection lifecycle and public error contracts' {
    InModuleScope Keldor {
        It 'returns one failure per unreachable target and continues the pipeline' {
            Mock New-PSSession { throw 'Fixture connection failure.' }
            Mock Remove-PSSession {}

            $results = @('missing01', 'missing02') | Get-KeldorHardwareInfo

            $results.Count | Should -Be 2
            @($results.ComputerName) | Should -Be @('missing01', 'missing02')
            @($results | Where-Object IsSuccessful).Count | Should -Be 0
            $results[0].ErrorMessage | Should -Be 'Fixture connection failure.'
            $results[0].PSObject.TypeNames[0] | Should -Be 'Keldor.HardwareInfo'
            Should -Invoke New-PSSession -Times 2 -Exactly
            Should -Invoke Remove-PSSession -Times 0 -Exactly
        }

        It 'reuses supplied sessions without opening or removing them' {
            $fixtureSession = New-MockObject -Type System.Management.Automation.Runspaces.PSSession
            Mock Get-KeldorRemoteSystemSnapshot {
                New-KeldorSystemSnapshot -ComputerName 'remote01' -Platform 'Linux'
            }
            Mock New-PSSession { throw 'Unexpected remote connection.' }
            Mock Remove-PSSession {}

            $result = Get-KeldorHardwareInfo -PSSession $fixtureSession

            $result.ComputerName | Should -Be 'remote01'
            Should -Invoke Get-KeldorRemoteSystemSnapshot -Times 1 -Exactly -ParameterFilter {
                [object]::ReferenceEquals($PSSession, $fixtureSession)
            }
            Should -Invoke New-PSSession -Times 0 -Exactly
            Should -Invoke Remove-PSSession -Times 0 -Exactly
        }

        It 'removes owned sessions after remote collection fails' {
            $fixtureSession = New-MockObject -Type System.Management.Automation.Runspaces.PSSession
            Mock New-PSSession { $fixtureSession }
            Mock Get-KeldorRemoteSystemSnapshot { throw 'Fixture query failure.' }
            Mock Remove-PSSession {}

            $result = Get-KeldorSystemInfo -ComputerName 'remote01'

            $result.ComputerName | Should -Be 'remote01'
            $result.IsSuccessful | Should -BeFalse
            $result.ErrorMessage | Should -Be 'Fixture query failure.'
            Should -Invoke Remove-PSSession -Times 1 -Exactly -ParameterFilter {
                [object]::ReferenceEquals(@($Session)[0], $fixtureSession)
            }
        }

        It 'forwards credentials only for explicitly requested remote targets' {
            $credential = [pscredential]::new('fixture', (ConvertTo-SecureString 'fixture' -AsPlainText -Force))
            Mock New-PSSession { throw 'Fixture connection failure.' }

            $null = Get-KeldorKernel -ComputerName 'missing01' -Credential $credential

            Should -Invoke New-PSSession -Times 1 -Exactly -ParameterFilter {
                $ComputerName -eq 'missing01' -and $Credential.UserName -eq 'fixture' -and $ErrorAction -eq 'Stop'
            }
        }

        It 'preserves Linux applicability errors and skips non-Linux results' {
            Mock Get-KeldorSystemSnapshot {
                New-KeldorSystemSnapshot -ComputerName 'windows01' -Platform 'Windows'
            }
            $errors = @()
            $result = Get-KeldorLinuxDistribution -ErrorAction SilentlyContinue -ErrorVariable errors

            $result | Should -BeNullOrEmpty
            $errors.Count | Should -Be 1
            $errors[0].CategoryInfo.Category | Should -Be 'InvalidOperation'
            $errors[0].FullyQualifiedErrorId | Should -Match '^Keldor.LinuxDistribution.NotApplicable'
            $errors[0].TargetObject | Should -Be 'windows01'
            { Get-KeldorLinuxDistribution -ErrorAction Stop } | Should -Throw '*not applicable*'
        }

        It 'preserves unidentified Linux-distribution failure results' {
            Mock Get-KeldorSystemSnapshot {
                New-KeldorSystemSnapshot -ComputerName 'missing01' -Platform $null -IsSuccessful $false `
                    -ErrorCategory 'ConnectionError' -ErrorCode 'Fixture.Unreachable' -ErrorMessage 'Unreachable.'
            }
            $result = Get-KeldorLinuxDistribution

            $result.IsSuccessful | Should -BeFalse
            $result.ErrorCode | Should -Be 'Fixture.Unreachable'
            $result.PSObject.TypeNames[0] | Should -Be 'Keldor.LinuxDistribution'
        }

        It 'uses one snapshot per local invocation without opening remote sessions' -ForEach @(
            @{ CommandName = 'Get-KeldorSystemInfo'; TypeName = 'Keldor.SystemInfo' }
            @{ CommandName = 'Get-KeldorOperatingSystem'; TypeName = 'Keldor.OperatingSystem' }
            @{ CommandName = 'Get-KeldorLinuxDistribution'; TypeName = 'Keldor.LinuxDistribution' }
            @{ CommandName = 'Get-KeldorKernel'; TypeName = 'Keldor.Kernel' }
            @{ CommandName = 'Get-KeldorUptime'; TypeName = 'Keldor.Uptime' }
            @{ CommandName = 'Get-KeldorHardwareInfo'; TypeName = 'Keldor.HardwareInfo' }
        ) {
            Mock Get-KeldorSystemSnapshot {
                New-KeldorSystemSnapshot -ComputerName 'linux01' -Platform 'Linux'
            }
            Mock New-PSSession { throw 'Unexpected remote connection.' }

            $result = & $CommandName

            $result.PSObject.TypeNames[0] | Should -Be $TypeName
            Should -Invoke Get-KeldorSystemSnapshot -Times 1 -Exactly
            Should -Invoke New-PSSession -Times 0 -Exactly
        }
    }
}
