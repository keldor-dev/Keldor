Describe 'Fleet command contract guardrails' {
    BeforeAll {
        $script:ModuleRoot = Split-Path -Parent $PSScriptRoot
        $script:RepositoryRoot = Split-Path -Parent (Split-Path -Parent $script:ModuleRoot)
        $script:TemplateRoot = Join-Path $script:RepositoryRoot 'docs/standards/powershell/templates'
        $script:TemplateFiles = @(
            'FleetReadOnlyFunction.ps1'
            'FleetInputObjectFunction.ps1'
            'FleetSessionFunction.ps1'
            'FleetShouldProcessFunction.ps1'
        ) | ForEach-Object { Join-Path $script:TemplateRoot $_ }

        function Get-KeldorParsedFile {
            param(
                [Parameter(Mandatory = $true)]
                [string]$Path
            )

            $tokens = $null
            $errors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors)

            if ($errors.Count -gt 0) {
                throw "Parse error in ${Path}: $($errors[0].Message)"
            }

            $ast
        }

        function Get-KeldorFunctionAst {
            param(
                [Parameter(Mandatory = $true)]
                [string]$Path
            )

            $ast = Get-KeldorParsedFile -Path $Path
            $ast.Find(
                {
                    param($node)
                    $node -is [System.Management.Automation.Language.FunctionDefinitionAst]
                },
                $true
            ) | Select-Object -First 1
        }

        function Get-KeldorParameterAttribute {
            param(
                [Parameter(Mandatory = $true)]
                [System.Management.Automation.Language.ParameterAst]$Parameter,

                [Parameter(Mandatory = $true)]
                [string]$AttributeName
            )

            $Parameter.Attributes |
                Where-Object { $_.TypeName.FullName -eq $AttributeName } |
                Select-Object -First 1
        }

        function Test-KeldorNamedArgumentTrue {
            param(
                [Parameter(Mandatory = $true)]
                [System.Management.Automation.Language.AttributeAst]$Attribute,

                [Parameter(Mandatory = $true)]
                [string]$Name
            )

            $argument = $Attribute.NamedArguments |
                Where-Object { $_.ArgumentName -eq $Name } |
                Select-Object -First 1

            $null -ne $argument -and $argument.Argument.Extent.Text -eq '$true'
        }

        . (Join-Path $script:TemplateRoot 'FleetReadOnlyFunction.ps1')
        . (Join-Path $script:TemplateRoot 'FleetInputObjectFunction.ps1')
        . (Join-Path $script:TemplateRoot 'FleetSessionFunction.ps1')
        . (Join-Path $script:TemplateRoot 'FleetShouldProcessFunction.ps1')
    }

    It 'keeps every dedicated fleet template parseable' {
        foreach ($path in $script:TemplateFiles) {
            { Get-KeldorParsedFile -Path $path } | Should -Not -Throw
        }
    }

    It 'uses canonical pipeline binding in the ComputerName templates' {
        foreach ($fileName in @('FleetReadOnlyFunction.ps1', 'FleetSessionFunction.ps1', 'FleetShouldProcessFunction.ps1')) {
            $functionAst = Get-KeldorFunctionAst -Path (Join-Path $script:TemplateRoot $fileName)
            $parameter = $functionAst.Body.ParamBlock.Parameters |
                Where-Object { $_.Name.VariablePath.UserPath -eq 'ComputerName' } |
                Select-Object -First 1
            $attribute = Get-KeldorParameterAttribute -Parameter $parameter -AttributeName 'Parameter'

            $parameter | Should -Not -BeNullOrEmpty
            Test-KeldorNamedArgumentTrue -Attribute $attribute -Name 'ValueFromPipeline' | Should -BeTrue
            Test-KeldorNamedArgumentTrue -Attribute $attribute -Name 'ValueFromPipelineByPropertyName' | Should -BeTrue
        }
    }

    It 'documents a rich InputObject pipeline contract' {
        $functionAst = Get-KeldorFunctionAst -Path (Join-Path $script:TemplateRoot 'FleetInputObjectFunction.ps1')
        $parameter = $functionAst.Body.ParamBlock.Parameters |
            Where-Object { $_.Name.VariablePath.UserPath -eq 'InputObject' } |
            Select-Object -First 1
        $attribute = Get-KeldorParameterAttribute -Parameter $parameter -AttributeName 'Parameter'

        $parameter | Should -Not -BeNullOrEmpty
        Test-KeldorNamedArgumentTrue -Attribute $attribute -Name 'ValueFromPipeline' | Should -BeTrue
        $functionAst.Extent.Text | Should -Match '(?s)\.PARAMETER InputObject.*ComputerName'
    }

    It 'uses meaningful ComputerName and Session parameter sets' {
        $command = Get-Command Invoke-KeldorExampleSessionQuery

        @($command.ParameterSets.Name) | Should -Contain 'ComputerName'
        @($command.ParameterSets.Name) | Should -Contain 'Session'
        $command.Parameters.Keys | Should -Contain 'ComputerName'
        $command.Parameters.Keys | Should -Contain 'PSSession'
    }

    It 'returns stable structured health results and preserves mixed-target success' {
        $results = @('server01', 'unavailable', 'server02') |
            Test-KeldorExampleHealth -ErrorAction SilentlyContinue

        $results.Count | Should -Be 3
        @($results.ComputerName) | Should -Contain 'server01'
        @($results.ComputerName) | Should -Contain 'server02'
        ($results | Where-Object ComputerName -EQ 'server01').IsHealthy | Should -BeTrue
        ($results | Where-Object ComputerName -EQ 'unavailable').IsHealthy | Should -BeNullOrEmpty
        ($results | Where-Object ComputerName -EQ 'unavailable').Status | Should -Be 'Unknown'

        foreach ($result in $results) {
            $result.PSObject.TypeNames[0] | Should -Be 'Keldor.ExampleHealthResult'
            $result.CheckedAt | Should -BeOfType ([datetimeoffset])
        }
    }

    It 'preserves native objects in the remote Output property' {
        $result = Invoke-KeldorExampleSessionQuery -ComputerName 'server01'

        $result.PSObject.TypeNames[0] | Should -Be 'Keldor.RemoteCommandResult'
        $result.Output | Should -BeOfType ([pscustomobject])
        $result.Duration | Should -BeOfType ([timespan])
        $result.AttemptCount | Should -BeOfType ([int])
    }

    It 'uses per-target ShouldProcess in the state-changing fleet template' {
        $path = Join-Path $script:TemplateRoot 'FleetShouldProcessFunction.ps1'
        $functionAst = Get-KeldorFunctionAst -Path $path
        $cmdletBinding = $functionAst.Body.ParamBlock.Attributes |
            Where-Object { $_.TypeName.FullName -eq 'CmdletBinding' } |
            Select-Object -First 1
        $shouldProcessCalls = $functionAst.FindAll(
            {
                param($node)
                $node -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and
                $node.Member.Value -eq 'ShouldProcess'
            },
            $true
        )

        Test-KeldorNamedArgumentTrue -Attribute $cmdletBinding -Name 'SupportsShouldProcess' | Should -BeTrue
        @($shouldProcessCalls).Count | Should -BeGreaterThan 0
    }

    It 'does not use formatting commands in dedicated fleet templates' {
        $prohibitedCommands = @('Format-Table', 'Format-List', 'Out-String')

        foreach ($path in $script:TemplateFiles) {
            $ast = Get-KeldorParsedFile -Path $path
            $commandNames = $ast.FindAll(
                {
                    param($node)
                    $node -is [System.Management.Automation.Language.CommandAst]
                },
                $true
            ) | ForEach-Object { $_.GetCommandName() }

            foreach ($commandName in $prohibitedCommands) {
                @($commandNames) | Should -Not -Contain $commandName
            }
        }
    }

    It 'does not expose plaintext password parameters in dedicated fleet templates' {
        foreach ($path in $script:TemplateFiles) {
            $functionAst = Get-KeldorFunctionAst -Path $path
            $unsafeParameters = $functionAst.Body.ParamBlock.Parameters | Where-Object {
                $_.Name.VariablePath.UserPath -match 'Password' -and
                $_.StaticType -eq [string]
            }

            @($unsafeParameters) | Should -BeNullOrEmpty
        }
    }

    It 'uses approved Boolean and timestamp names in normalized template results' {
        $healthResult = Test-KeldorExampleHealth -ComputerName 'server01'
        $changeResult = Set-KeldorExampleFleetState -ComputerName 'server01' -Confirm:$false

        $healthResult.IsHealthy | Should -BeOfType ([bool])
        $healthResult.CheckedAt | Should -BeOfType ([datetimeoffset])
        $changeResult.IsSuccessful | Should -BeOfType ([bool])
        $changeResult.HasChanges | Should -BeOfType ([bool])
        $changeResult.CompletedAt | Should -BeOfType ([datetimeoffset])
    }

    It 'prevents new formatting commands in public implementations' {
        $baseline = Import-PowerShellDataFile -Path (Join-Path $PSScriptRoot 'FleetContractBaseline.psd1')
        $violations = @()

        foreach ($path in Get-ChildItem -Path (Join-Path $script:ModuleRoot 'Public') -Filter '*.ps1' -File -Recurse) {
            $ast = Get-KeldorParsedFile -Path $path.FullName
            $functionName = $path.BaseName
            $formatCommands = $ast.FindAll(
                {
                    param($node)
                    $node -is [System.Management.Automation.Language.CommandAst] -and
                    $node.GetCommandName() -in @('Format-Table', 'Format-List', 'Out-String')
                },
                $true
            ) | ForEach-Object { $_.GetCommandName() }

            foreach ($formatCommand in $formatCommands) {
                $allowed = @($baseline.AllowedPublicFormattingCommands[$functionName])
                if ($formatCommand -notin $allowed) {
                    $violations += "${functionName}: ${formatCommand}"
                }
            }
        }

        $violations | Should -BeNullOrEmpty
    }
}
