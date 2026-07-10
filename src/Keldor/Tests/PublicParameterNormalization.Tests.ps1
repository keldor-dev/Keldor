Describe "Public parameter normalization" {
    BeforeAll {
        $script:ModuleRoot = Split-Path -Parent $PSScriptRoot

        function Get-KeldorFunctionParameter {
            param(
                [Parameter(Mandatory = $true)]
                [string]$FunctionName,

                [Parameter(Mandatory = $true)]
                [string]$ParameterName
            )

            $functionFile = Get-ChildItem -Path (Join-Path $script:ModuleRoot 'Public') -File -Recurse |
                Where-Object { $_.BaseName -eq $FunctionName } |
                Select-Object -First 1

            $tokens = $null
            $errors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($functionFile.FullName, [ref]$tokens, [ref]$errors)

            if ($errors) {
                throw "Parse error in $($functionFile.FullName): $($errors[0].Message)"
            }

            $functionAst = $ast.Find(
                {
                    param($node)
                    $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
                    $node.Name -eq $FunctionName
                },
                $true
            )

            $functionAst.Body.ParamBlock.Parameters |
                Where-Object { $_.Name.VariablePath.UserPath -eq $ParameterName } |
                Select-Object -First 1
        }

        function Get-KeldorParameterAliases {
            param(
                [Parameter(Mandatory = $true)]
                [System.Management.Automation.Language.ParameterAst]$ParameterAst
            )

            $aliases = @()
            foreach ($attribute in $ParameterAst.Attributes) {
                if ($attribute.TypeName.FullName -eq 'Alias') {
                    foreach ($argument in $attribute.PositionalArguments) {
                        if ($argument -is [System.Management.Automation.Language.StringConstantExpressionAst]) {
                            $aliases += $argument.Value
                        } else {
                            $aliases += $argument.Extent.Text.Trim("'`"")
                        }
                    }
                }
            }

            $aliases
        }

        function Test-KeldorParameterHasValidateNotNullOrEmpty {
            param(
                [Parameter(Mandatory = $true)]
                [System.Management.Automation.Language.ParameterAst]$ParameterAst
            )

            [bool]($ParameterAst.Attributes | Where-Object { $_.TypeName.FullName -eq 'ValidateNotNullOrEmpty' })
        }

        $script:ExpectedParameters = @(
            @{ Function = 'Set-AutoLoadPreference'; Parameter = 'Mode'; Aliases = @(); ValidateNotNullOrEmpty = $false }
            @{ Function = 'ConvertFrom-BuildNumber'; Parameter = 'BuildNumber'; Aliases = @('Build'); ValidateNotNullOrEmpty = $true }
            @{ Function = 'Convert-ImageToBase64'; Parameter = 'Path'; Aliases = @('ImagePath'); ValidateNotNullOrEmpty = $true }
            @{ Function = 'Open-FileWithCMTrace'; Parameter = 'Path'; Aliases = @('FileName', 'File', 'Name'); ValidateNotNullOrEmpty = $true }
            @{ Function = 'Get-DirectoryStat'; Parameter = 'Path'; Aliases = @('DirectoryName', 'Dir', 'Folder', 'UNC'); ValidateNotNullOrEmpty = $true }
            @{ Function = 'Convert-IPtoINT64'; Parameter = 'IPAddress'; Aliases = @('IP', 'IPs', 'IPv4', 'Address'); ValidateNotNullOrEmpty = $false }
            @{ Function = 'Format-IPList'; Parameter = 'IPAddress'; Aliases = @('IP', 'IPs', 'IPv4', 'Address', 'IPAddresses'); ValidateNotNullOrEmpty = $true }
            @{ Function = 'Get-IPrange'; Parameter = 'IPAddress'; Aliases = @('IP', 'IPs', 'IPv4', 'Address', 'IPv4Address'); ValidateNotNullOrEmpty = $false }
            @{ Function = 'Find-UserProfile'; Parameter = 'UserName'; Aliases = @('Username', 'User', 'SamAccountName'); ValidateNotNullOrEmpty = $false }
            @{ Function = 'Find-UserProfileWithPSTSearch'; Parameter = 'UserName'; Aliases = @('Username', 'User', 'SamAccountName'); ValidateNotNullOrEmpty = $false }
            @{ Function = 'Get-LockedOutStatus'; Parameter = 'UserName'; Aliases = @('Username', 'User', 'SamAccountName'); ValidateNotNullOrEmpty = $false }
            @{ Function = 'Set-ADProfilePicture'; Parameter = 'UserName'; Aliases = @('Username', 'User', 'SamAccountName'); ValidateNotNullOrEmpty = $true }
            @{ Function = 'Copy-UserProfile'; Parameter = 'UserName'; Aliases = @('User', 'Username', 'SamAccountName'); ValidateNotNullOrEmpty = $true }
            @{ Function = 'Copy-UserProfile'; Parameter = 'DestinationPath'; Aliases = @('Destination', 'Dest', 'DestinationFolder', 'DestFolder'); ValidateNotNullOrEmpty = $false }
        )
    }

    It "uses canonical parameter names and preserves compatibility aliases" {
        foreach ($expected in $script:ExpectedParameters) {
            $parameter = Get-KeldorFunctionParameter -FunctionName $expected.Function -ParameterName $expected.Parameter

            $parameter | Should -Not -BeNullOrEmpty
            $aliases = Get-KeldorParameterAliases -ParameterAst $parameter

            foreach ($alias in $expected.Aliases) {
                $aliases | Should -Contain $alias
            }
        }
    }

    It "keeps safe mandatory parameter validation" {
        foreach ($expected in $script:ExpectedParameters | Where-Object { $_.ValidateNotNullOrEmpty }) {
            $parameter = Get-KeldorFunctionParameter -FunctionName $expected.Function -ParameterName $expected.Parameter

            Test-KeldorParameterHasValidateNotNullOrEmpty -ParameterAst $parameter | Should -BeTrue
        }
    }
}
