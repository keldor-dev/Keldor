@{
    ModuleName                = 'Keldor'
    SourcePath                = 'src/Keldor'
    ManifestPath              = 'src/Keldor/Keldor.psd1'
    TestPath                  = 'src/Keldor/Tests'
    OutputPath                = 'out'
    AnalyzerSettingsPath      = 'PSScriptAnalyzerSettings.psd1'
    RequiredPowerShellVersion = '5.1'
    ExpectedManifestVersion   = '0.1.0'
    ExcludedPaths             = @(
        '.DS_Store'
        'Tests'
    )
}
