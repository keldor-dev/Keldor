Describe "Keldor Module" {
    It "Should import without errors" {
        Import-Module Keldor -ErrorAction Stop
    }
    It "Should have expected functions" {
        (Get-Command -Module Keldor).Name | Should -Contain "Get-WSToolsVersion"
    }
}
