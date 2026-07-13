Describe 'Platform detection architecture' {
    BeforeAll {
        $script:ModuleRoot = Split-Path -Parent $PSScriptRoot
        $script:CanonicalPath = Join-Path $script:ModuleRoot 'Public/Common/Get-KeldorPlatform.ps1'
    }

    It 'has exactly one Get-KeldorPlatform implementation in module source' {
        $definitions = foreach ($file in Get-ChildItem -Path $script:ModuleRoot -Filter '*.ps1' -File -Recurse) {
            if ($file.FullName -like "*$([IO.Path]::DirectorySeparatorChar)Tests$([IO.Path]::DirectorySeparatorChar)*") {
                continue
            }

            $tokens = $null
            $errors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors)
            $ast.FindAll(
                {
                    param($node)
                    $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
                    $node.Name -eq 'Get-KeldorPlatform'
                },
                $true
            )
        }

        @($definitions).Count | Should -Be 1
    }

    It 'keeps direct platform checks inside Get-KeldorPlatform' {
        $violations = foreach ($directory in 'Public', 'Private') {
            foreach ($file in Get-ChildItem -Path (Join-Path $script:ModuleRoot $directory) -Filter '*.ps1' -File -Recurse) {
                if ($file.FullName -eq $script:CanonicalPath) {
                    continue
                }

                $tokens = $null
                $errors = $null
                $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors)
                $platformNodes = $ast.FindAll(
                    {
                        param($node)
                        ($node -is [System.Management.Automation.Language.VariableExpressionAst] -and
                        $node.VariablePath.UserPath -in @('IsWindows', 'IsMacOS', 'IsLinux')) -or
                        ($node -is [System.Management.Automation.Language.TypeExpressionAst] -and
                        $node.TypeName.FullName -eq 'System.Runtime.InteropServices.RuntimeInformation') -or
                        ($node -is [System.Management.Automation.Language.CommandAst] -and
                        $node.GetCommandName() -eq 'uname')
                    },
                    $true
                )

                foreach ($node in $platformNodes) {
                    "$($file.FullName):$($node.Extent.StartLineNumber): $($node.Extent.Text)"
                }
            }
        }

        $violations | Should -BeNullOrEmpty
    }
}
