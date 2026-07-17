$invokeCommandModuleRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $invokeCommandModuleRoot 'Keldor.psd1') -Force

Describe 'Invoke-KeldorCommand public contract' {
    BeforeAll {
        $script:ModuleRoot = Split-Path -Parent $PSScriptRoot
        $script:CommandPath = Join-Path $script:ModuleRoot 'Public/Common/Invoke-KeldorCommand.ps1'
        $script:ExpectedProperties = @(
            'ComputerName', 'Target', 'TargetType', 'Transport', 'SessionId', 'InvocationType', 'CommandName',
            'Succeeded', 'Status', 'AttemptCount', 'StartedAt', 'CompletedAt', 'Duration', 'Output', 'Errors',
            'ErrorId', 'ErrorCategory', 'ErrorMessage', 'ExceptionType', 'WasTimedOut', 'WasRetried',
            'PowerShellVersion', 'RunspaceId', 'CorrelationId'
        )
    }

    It 'exports the command without adding an alias' {
        $command = Get-Command -Name Invoke-KeldorCommand -Module Keldor

        $command.CommandType | Should -Be 'Function'
        Get-Alias -Definition Invoke-KeldorCommand -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
    }

    It 'has the eight stable and mutually exclusive parameter sets' {
        $command = Get-Command -Name Invoke-KeldorCommand -Module Keldor

        @($command.ParameterSets.Name | Sort-Object) | Should -Be @(
            'LocalKeldorCommand', 'LocalScriptBlock', 'SessionKeldorCommand', 'SessionScriptBlock',
            'SshKeldorCommand', 'SshScriptBlock', 'WsManKeldorCommand', 'WsManScriptBlock'
        )
        $command.Parameters.Keys | Should -Contain 'Local'
        $command.Parameters.Keys | Should -Contain 'Session'
        $command.Parameters.Keys | Should -Contain 'ComputerName'
        $command.Parameters.Keys | Should -Contain 'HostName'
        $command.Parameters.Keys | Should -Contain 'ScriptBlock'
        $command.Parameters.Keys | Should -Contain 'KeldorCommand'
    }

    It 'provides complete help and the canonical link' {
        $help = Get-Help -Name Invoke-KeldorCommand -Full

        $help.Synopsis | Should -Not -BeNullOrEmpty
        $help.Description.Text | Should -Not -BeNullOrEmpty
        @($help.Examples.Example).Count | Should -BeGreaterOrEqual 8
        $help.InputTypes.InputType.Type.Name | Should -Not -BeNullOrEmpty
        $help.ReturnValues.ReturnValue.Type.Name | Should -Match '^Keldor\.'
        $help.RelatedLinks.NavigationLink.Uri | Should -Contain (
            'https://docs.keldor.dev/powershell/keldor/Invoke-KeldorCommand'
        )
    }

    It 'runs local script blocks in-process and forwards arguments' {
        $runspaceId = $Host.Runspace.InstanceId
        $result = Invoke-KeldorCommand -Local -ScriptBlock {
            param($Value)
            [pscustomobject]@{ Value = $Value; RunspaceId = $Host.Runspace.InstanceId }
        } -ArgumentList 42

        $result.Succeeded | Should -BeTrue
        $result.Status | Should -Be 'Succeeded'
        $result.Transport | Should -Be 'Local'
        $result.TargetType | Should -Be 'Local'
        $result.Output[0].Value | Should -Be 42
        $result.Output[0].RunspaceId | Should -Be $runspaceId
        $result.RunspaceId | Should -Be $runspaceId
    }

    It 'returns the stable structured result properties and native types' {
        $result = Invoke-KeldorCommand -Local -ScriptBlock { Get-Date }

        @($result.PSObject.Properties.Name) | Should -Be $script:ExpectedProperties
        $result.PSObject.TypeNames[0] | Should -Be 'Keldor.CommandExecutionResult'
        $result.StartedAt | Should -BeOfType ([datetimeoffset])
        $result.CompletedAt | Should -BeOfType ([datetimeoffset])
        $result.Duration | Should -BeOfType ([timespan])
        $result.CorrelationId | Should -BeOfType ([guid])
        $result.AttemptCount | Should -BeOfType ([int])
    }

    It 'returns raw local output without result envelopes' {
        $output = Invoke-KeldorCommand -Local -ScriptBlock { [pscustomobject]@{ Value = 7 } } -RawOutput

        $output.Value | Should -Be 7
        $output.PSObject.TypeNames | Should -Not -Contain 'Keldor.CommandExecutionResult'
    }

    It 'captures local command errors inside structured results' {
        $streamErrors = @()
        $result = Invoke-KeldorCommand -Local -ScriptBlock {
            Write-Error 'Fixture failure.'
        } -ErrorVariable streamErrors

        $streamErrors | Should -BeNullOrEmpty
        $result.Succeeded | Should -BeFalse
        $result.Status | Should -Be 'Failed'
        $result.Errors.Count | Should -Be 1
        $result.ErrorMessage | Should -Match 'Fixture failure'
    }

    It 'invokes a validated installed local Keldor command with object parameters' {
        $result = Invoke-KeldorCommand -Local -KeldorCommand 'Get-KeldorPlatform' -Parameter @{}

        $result.Succeeded | Should -BeTrue
        $result.InvocationType | Should -Be 'KeldorCommand'
        $result.CommandName | Should -Be 'Get-KeldorPlatform'
        $result.Output.Count | Should -Be 1
    }

    It 'normalizes a missing installed Keldor command' {
        $result = Invoke-KeldorCommand -Local -KeldorCommand 'Get-KeldorDoesNotExist'

        $result.Succeeded | Should -BeFalse
        $result.ErrorId | Should -Be 'Keldor.RemoteCommandUnavailable'
    }

    It 'rejects malicious command names' -ForEach @(
        'Get-KeldorSystemInfo; Remove-Item C:\'
        'Get-KeldorSystemInfo | Out-File result.txt'
        '$(Get-Process)'
        'Get-KeldorSystemInfo -Verbose'
        'Get-Process'
    ) {
        {
            Invoke-KeldorCommand -Local -KeldorCommand $_ -ErrorAction Stop
        } | Should -Throw -ErrorId 'Keldor.InvalidRemoteCommandName*'
    }

    It 'rejects empty, whitespace-bearing, and control-character remote targets' -ForEach @(
        'server 01'
        "server`t01"
        '   '
    ) {
        {
            Invoke-KeldorCommand -ComputerName $_ -ScriptBlock { 1 } -ErrorAction Stop
        } | Should -Throw -ErrorId 'Keldor.InvalidRemoteTarget*'
    }

    It 'preserves exact duplicate WSMan target order and one correlation id' {
        InModuleScope Keldor {
            $script:StartedTargetCount = 0
            $script:StartedBeforeFirstResult = 0
            Mock Start-KeldorCommandJob { [void]$script:StartedTargetCount++ }
            Mock Invoke-KeldorCommandRemoteTarget {
                if ($script:StartedBeforeFirstResult -eq 0) {
                    $script:StartedBeforeFirstResult = $script:StartedTargetCount
                }
                $now = [datetimeoffset]::UtcNow
                New-KeldorCommandExecutionResult `
                    -TargetDescriptor $TargetDescriptor `
                    -InvocationType $InvocationType `
                    -CommandName $CommandName `
                    -Succeeded $true `
                    -Status Succeeded `
                    -AttemptCount 1 `
                    -StartedAt $now `
                    -CompletedAt $now `
                    -Output @($TargetDescriptor.Target) `
                    -CorrelationId $CorrelationId
            }

            $results = @('server02', 'server01', 'server02') |
                Invoke-KeldorCommand -ScriptBlock { hostname } -ThrottleLimit 2

            @($results.Target) | Should -Be @('server02', 'server01', 'server02')
            @($results.CorrelationId | Select-Object -Unique).Count | Should -Be 1
            $script:StartedBeforeFirstResult | Should -Be 2
            Should -Invoke Invoke-KeldorCommandRemoteTarget -Times 3 -Exactly
        }
    }

    It 'forwards WSMan connection parameters to the private engine' {
        InModuleScope Keldor {
            $credential = New-Object pscredential 'user', (ConvertTo-SecureString 'test' -AsPlainText -Force)
            $option = New-PSSessionOption
            Mock Start-KeldorCommandJob
            Mock Invoke-KeldorCommandRemoteTarget {
                $script:ForwardedConnectionParameter = $ConnectionParameter
                $now = [datetimeoffset]::UtcNow
                New-KeldorCommandExecutionResult -TargetDescriptor $TargetDescriptor -InvocationType ScriptBlock `
                    -Succeeded $true -Status Succeeded -AttemptCount 1 -StartedAt $now -CompletedAt $now `
                    -CorrelationId $CorrelationId
            }

            Invoke-KeldorCommand -ComputerName server01 -ScriptBlock { 1 } -Credential $credential `
                -Authentication Negotiate -Port 5986 -UseSSL -ConfigurationName TestEndpoint `
                -SessionOption $option | Out-Null

            $script:ForwardedConnectionParameter.Credential | Should -Be $credential
            $script:ForwardedConnectionParameter.Authentication | Should -Be 'Negotiate'
            $script:ForwardedConnectionParameter.Port | Should -Be 5986
            $script:ForwardedConnectionParameter.UseSSL | Should -BeTrue
            $script:ForwardedConnectionParameter.ConfigurationName | Should -Be 'TestEndpoint'
            $script:ForwardedConnectionParameter.SessionOption | Should -Be $option
        }
    }

    It 'forwards supported SSH parameters on PowerShell Core' -Skip:($PSVersionTable.PSEdition -ne 'Core') {
        InModuleScope Keldor {
            Mock Start-KeldorCommandJob
            Mock Invoke-KeldorCommandRemoteTarget {
                $script:ForwardedSshParameter = $ConnectionParameter
                $now = [datetimeoffset]::UtcNow
                New-KeldorCommandExecutionResult -TargetDescriptor $TargetDescriptor -InvocationType ScriptBlock `
                    -Succeeded $true -Status Succeeded -AttemptCount 1 -StartedAt $now -CompletedAt $now `
                    -CorrelationId $CorrelationId
            }

            Invoke-KeldorCommand -HostName linux01 -UserName automation -KeyFilePath ./fixture-key `
                -Port 22 -Subsystem powershell -ConnectingTimeout 5000 -SSHTransport -ScriptBlock { 1 } | Out-Null

            $script:ForwardedSshParameter.UserName | Should -Be 'automation'
            $script:ForwardedSshParameter.KeyFilePath | Should -Be './fixture-key'
            $script:ForwardedSshParameter.Port | Should -Be 22
            $script:ForwardedSshParameter.Subsystem | Should -Be 'powershell'
            $script:ForwardedSshParameter.ConnectingTimeout | Should -Be 5000
            $script:ForwardedSshParameter.SSHTransport | Should -BeTrue
        }
    }

    It 'contains no session disposal or unsafe execution behavior' {
        $productionPaths = @($script:CommandPath) + @(
            Get-ChildItem (Join-Path $script:ModuleRoot 'Private/Common') -Filter '*Keldor*Command*.ps1' -File |
                Select-Object -ExpandProperty FullName
        )
        $content = ($productionPaths | ForEach-Object { Get-Content -LiteralPath $_ -Raw }) -join "`n"

        $content | Should -Not -Match '\bRemove-PSSession\b|\bInvoke-Expression\b|\bWrite-Host\b'
        $content | Should -Not -Match 'TrustedHosts|Enable-PSRemoting|Set-ExecutionPolicy|Set-PSSessionConfiguration'
        $content | Should -Not -Match 'Install-Module|Save-Module|Publish-Module|New-NetFirewallRule'
    }

    It 'parses every orchestration production file' {
        $paths = @($script:CommandPath) + @(
            Get-ChildItem (Join-Path $script:ModuleRoot 'Private/Common') -Filter '*Keldor*Command*.ps1' -File |
                Select-Object -ExpandProperty FullName
        )
        foreach ($path in $paths) {
            $tokens = $null
            $errors = $null
            [void][System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors)
            $errors | Should -BeNullOrEmpty
        }
    }
}

Describe 'Invoke-KeldorCommand private execution policy' {
    InModuleScope Keldor {
        It 'builds installed-command logic that imports and validates the Keldor module' {
            $text = (New-KeldorRemoteCommandScriptBlock).ToString()

            $text | Should -Match 'Import-Module\s+-Name\s+Keldor'
            $text | Should -Match 'Get-Command\s+-Name\s+\$KeldorCommand\s+-Module\s+Keldor'
            $text | Should -Match '&\s+\$command\s+@Parameter'
            $text | Should -Not -Match 'Invoke-Expression'
        }

        It 'retries only a connection failure and records the attempt count' {
            $script:Attempt = 0
            Mock Start-KeldorCommandJob {
                $script:Attempt++
                if ($script:Attempt -eq 1) {
                    $exception = New-Object System.Management.Automation.Remoting.PSRemotingTransportException (
                        'Temporary connection failure.'
                    )
                    $record = New-Object System.Management.Automation.ErrorRecord (
                        $exception,
                        'OpenError',
                        [System.Management.Automation.ErrorCategory]::OpenError,
                        'server01'
                    )
                    throw $record
                }
                Start-Job -ScriptBlock { 42 }
            }
            $descriptor = [pscustomobject]@{
                ComputerName = 'server01'; Target = 'server01'; TargetType = 'ComputerName'; Transport = 'WSMan'
                SessionId = $null; TargetObject = $null
            }

            $result = Invoke-KeldorCommandRemoteTarget -TargetDescriptor $descriptor -ScriptBlock { 42 } `
                -RetryCount 1 -RetryDelaySec 0 -InvocationType ScriptBlock -CorrelationId ([guid]::NewGuid())

            $result.Succeeded | Should -BeTrue
            $result.AttemptCount | Should -Be 2
            $result.WasRetried | Should -BeTrue
        }

        It 'does not retry remote command logic failures' {
            Mock Start-KeldorCommandJob {
                throw 'User command failure.'
            }
            $descriptor = [pscustomobject]@{
                ComputerName = 'server01'; Target = 'server01'; TargetType = 'ComputerName'; Transport = 'WSMan'
                SessionId = $null; TargetObject = $null
            }

            $result = Invoke-KeldorCommandRemoteTarget -TargetDescriptor $descriptor -ScriptBlock { throw 'failure' } `
                -RetryCount 2 -RetryDelaySec 0 -InvocationType ScriptBlock -CorrelationId ([guid]::NewGuid())

            $result.Succeeded | Should -BeFalse
            $result.AttemptCount | Should -Be 1
            $result.ErrorId | Should -Be 'Keldor.RemoteInvocationFailed'
        }

        It 'times out a remote invocation job and cleans it up' {
            Mock Start-KeldorCommandJob { Start-Job -ScriptBlock { Start-Sleep -Seconds 5 } }
            $descriptor = [pscustomobject]@{
                ComputerName = 'server01'; Target = 'server01'; TargetType = 'ComputerName'; Transport = 'WSMan'
                SessionId = $null; TargetObject = $null
            }

            $result = Invoke-KeldorCommandRemoteTarget -TargetDescriptor $descriptor -ScriptBlock { 1 } `
                -TimeoutSec 1 -RetryCount 0 -RetryDelaySec 0 -InvocationType ScriptBlock `
                -CorrelationId ([guid]::NewGuid())

            $result.Status | Should -Be 'TimedOut'
            $result.WasTimedOut | Should -BeTrue
            $result.ErrorId | Should -Be 'Keldor.RemoteInvocationTimedOut'
        }
    }
}

Describe 'Invoke-KeldorCommand opt-in integration' -Tag 'Integration' {
    It 'executes against an explicitly configured WSMan fixture' `
        -Skip:([string]::IsNullOrWhiteSpace($env:KELDOR_TEST_WSMAN_HOST)) {
        $result = Invoke-KeldorCommand -ComputerName $env:KELDOR_TEST_WSMAN_HOST -ScriptBlock {
            [Environment]::MachineName
        } -TimeoutSec 30

        $result.Succeeded | Should -BeTrue
        $result.Transport | Should -Be 'WSMan'
    }

    It 'executes against an explicitly configured SSH fixture' -Skip:(
        $PSVersionTable.PSEdition -ne 'Core' -or
        [string]::IsNullOrWhiteSpace($env:KELDOR_TEST_SSH_HOST) -or
        [string]::IsNullOrWhiteSpace($env:KELDOR_TEST_SSH_USER) -or
        [string]::IsNullOrWhiteSpace($env:KELDOR_TEST_SSH_KEY_FILE)
    ) {
        $parameters = @{
            HostName    = $env:KELDOR_TEST_SSH_HOST
            UserName    = $env:KELDOR_TEST_SSH_USER
            KeyFilePath = $env:KELDOR_TEST_SSH_KEY_FILE
            ScriptBlock = { [Environment]::MachineName }
            TimeoutSec  = 30
        }
        if ($env:KELDOR_TEST_SSH_PORT) {
            $parameters.Port = [int]$env:KELDOR_TEST_SSH_PORT
        }

        $result = Invoke-KeldorCommand @parameters

        $result.Succeeded | Should -BeTrue
        $result.Transport | Should -Be 'SSH'
    }
}
