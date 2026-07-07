Describe "Keldor environment helpers" {
    BeforeAll {
        $ModuleRoot = Split-Path -Parent $PSScriptRoot
        . (Join-Path $ModuleRoot 'Private/Common/Get-KeldorPlatform.ps1')
        . (Join-Path $ModuleRoot 'Private/Common/Test-KeldorAdministrator.ps1')
        . (Join-Path $ModuleRoot 'Private/Windows/Test-KeldorActiveDirectoryModule.ps1')
        . (Join-Path $ModuleRoot 'Private/Windows/Assert-KeldorActiveDirectoryModule.ps1')
    }

    Context "Test-KeldorAdministrator" {
        It "returns false on non-Windows platforms" {
            Mock Get-KeldorPlatform { 'Linux' }

            Test-KeldorAdministrator | Should -BeFalse
        }
    }

    Context "Test-KeldorActiveDirectoryModule" {
        It "returns a structured unavailable status when the module is absent" {
            Mock Get-Module {}

            $result = Test-KeldorActiveDirectoryModule -Quiet

            $result.Name | Should -Be 'ActiveDirectory'
            $result.Available | Should -BeFalse
            $result.Imported | Should -BeFalse
            $result.Message | Should -Match 'not installed|not available'
        }

        It "returns true when the module is available in Boolean mode" {
            Mock Get-Module { [pscustomobject]@{ Name = 'ActiveDirectory' } }

            Test-KeldorActiveDirectoryModule -AsBoolean -Quiet | Should -BeTrue
        }

        It "imports the module when requested" {
            Mock Get-Module { [pscustomobject]@{ Name = 'ActiveDirectory' } }
            Mock Import-Module {}

            $result = Test-KeldorActiveDirectoryModule -Import -Quiet

            $result.Available | Should -BeTrue
            $result.Imported | Should -BeTrue
            Assert-MockCalled Import-Module -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'ActiveDirectory'
            }
        }
    }

    Context "Assert-KeldorActiveDirectoryModule" {
        It "throws when the module is unavailable" {
            Mock Get-Module {}

            { Assert-KeldorActiveDirectoryModule } | Should -Throw '*ActiveDirectory module*'
        }
    }
}
