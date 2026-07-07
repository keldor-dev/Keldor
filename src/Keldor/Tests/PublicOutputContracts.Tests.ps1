Describe "Public output contracts" {
    BeforeAll {
        $script:ModuleRoot = Split-Path -Parent $PSScriptRoot

        function Get-KeldorPublicFunctionText {
            param(
                [Parameter(Mandatory=$true)]
                [string]$FunctionName
            )

            $functionFile = Get-ChildItem -Path (Join-Path $script:ModuleRoot 'Public') -File -Recurse |
                Where-Object { $_.BaseName -eq $FunctionName } |
                Select-Object -First 1

            Get-Content -Path $functionFile.FullName -Raw
        }

        function Assert-KeldorTextContains {
            param(
                [Parameter(Mandatory=$true)]
                [string]$Text,

                [Parameter(Mandatory=$true)]
                [string[]]$Patterns
            )

            foreach ($pattern in $Patterns) {
                $Text | Should -Match $pattern
            }
        }
    }

    It "keeps canonical and legacy build number properties" {
        . (Join-Path $script:ModuleRoot 'Public/Windows/ConvertFrom-BuildNumber.ps1')

        $result = ConvertFrom-BuildNumber -BuildNumber 20348
        $properties = @($result.PSObject.Properties.Name)

        $properties | Should -Contain 'OperatingSystem'
        $properties | Should -Contain 'BuildNumber'
        $properties | Should -Contain 'OS'
        $properties | Should -Contain 'Build'
        $result.OperatingSystem | Should -Be $result.OS
        $result.BuildNumber | Should -Be $result.Build
    }

    It "defines canonical low-risk inventory output properties" {
        Assert-KeldorTextContains -Text (Get-KeldorPublicFunctionText -FunctionName 'Get-SerialNumber') -Patterns @(
            '(?m)^\s*ComputerName\s*=',
            '(?m)^\s*SerialNumber\s*='
        )

        Assert-KeldorTextContains -Text (Get-KeldorPublicFunctionText -FunctionName 'Get-ComputerHWInfo') -Patterns @(
            '(?m)^\s*ComputerName\s*=',
            '(?m)^\s*BiosVendor\s*=',
            '(?m)^\s*BiosVersion\s*=',
            '(?m)^\s*BiosReleaseDate\s*='
        )

        Assert-KeldorTextContains -Text (Get-KeldorPublicFunctionText -FunctionName 'Get-ComputerADSite') -Patterns @(
            '(?m)^\s*ComputerName\s*=',
            '(?m)^\s*SiteName\s*=',
            '(?m)^\s*Site\s*='
        )
    }

    It "defines canonical account and holiday output properties while preserving legacy fields" {
        Assert-KeldorTextContains -Text (Get-KeldorPublicFunctionText -FunctionName 'Get-DaysSinceLastLogon') -Patterns @(
            '(?m)^\s*Name\s*=',
            '(?m)^\s*UserName\s*=',
            '(?m)^\s*CheckedAt\s*='
        )

        Assert-KeldorTextContains -Text (Get-KeldorPublicFunctionText -FunctionName 'Show-FederalHoliday') -Patterns @(
            "Name='HolidayDate'",
            'Select-Object Name,Year,Date',
            'Select-Object Name,Date'
        )
    }

    It "defines canonical service and registry output properties while preserving legacy fields" {
        Assert-KeldorTextContains -Text (Get-KeldorPublicFunctionText -FunctionName 'Get-SplunkStatus') -Patterns @(
            '(?m)^\s*ComputerName\s*=',
            '(?m)^\s*Status\s*=',
            '(?m)^\s*SplunkStatus\s*='
        )

        Assert-KeldorTextContains -Text (Get-KeldorPublicFunctionText -FunctionName 'Get-SCHANNELSetting') -Patterns @(
            '(?m)^\s*IsDisabledByDefault\s*=',
            '(?m)^\s*IsEnabled\s*=',
            '(?m)^\s*RegistryPath\s*=',
            '(?m)^\s*FullPath\s*='
        )

        Assert-KeldorTextContains -Text (Get-KeldorPublicFunctionText -FunctionName 'Get-HttpHeaderSetting') -Patterns @(
            '(?m)^\s*IsDisabled\s*=',
            '(?m)^\s*RegistryPath\s*=',
            '(?m)^\s*FullPath\s*='
        )
    }
}
