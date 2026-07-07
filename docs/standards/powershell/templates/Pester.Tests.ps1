BeforeAll {
    $RepoRoot = Join-Path -Path $PSScriptRoot -ChildPath '..'
    $ManifestPath = Join-Path -Path $RepoRoot -ChildPath '<ModuleName>.psd1'

    Import-Module $ManifestPath -Force
}

Describe '<ModuleName>' {
    It 'imports successfully' {
        Get-Module -Name '<ModuleName>' | Should -Not -BeNullOrEmpty
    }

    It 'exports expected commands' {
        Get-Command -Module '<ModuleName>' | Should -Not -BeNullOrEmpty
    }
}
