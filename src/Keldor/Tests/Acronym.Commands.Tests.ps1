BeforeAll {
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '../Keldor.psd1'
    Import-Module $ModulePath -Force

    function Write-TestAcronymCatalog {
        param(
            [string]$Path,
            [object[]]$Record
        )

        [System.IO.File]::WriteAllText(
            $Path,
            (ConvertTo-Json -InputObject @($Record) -Depth 10),
            (New-Object System.Text.UTF8Encoding($false))
        )
    }

    function New-TestAcronymRecord {
        param(
            [string]$Acronym,
            [string]$Meaning,
            [string]$Category = 'General',
            [string]$Notes = ''
        )

        [PSCustomObject][ordered]@{
            Acronym  = $Acronym
            Meaning  = $Meaning
            Category = $Category
            Notes    = $Notes
        }
    }
}

Describe 'Find-KeldorAcronym' {
    BeforeEach {
        $AdditionalPath = Join-Path $TestDrive 'additional.json'
        $BundledApi = Get-KeldorAcronym -Acronym API | Select-Object -First 1
        Write-TestAcronymCatalog -Path $AdditionalPath -Record @(
            (New-TestAcronymRecord -Acronym 'ZZTEST' -Meaning 'Regex [literal]* value' -Category 'Testing' -Notes 'pipe | note'),
            $BundledApi,
            (New-TestAcronymRecord -Acronym 'API' -Meaning 'Alternate Program Interface' -Category 'Testing')
        )
    }

    It 'accepts positional, case-insensitive partial searches' {
        @(Find-KeldorAcronym doj).Count | Should -BeGreaterThan 0
    }

    It 'treats regex and wildcard characters literally' {
        @(Find-KeldorAcronym '[literal]*' -AdditionalCatalogPath $AdditionalPath).Acronym |
            Should -Contain 'ZZTEST'
    }

    It 'matches only acronyms in exact mode and supports its alias' {
        @(Find-KDAcronym ZZTEST -Exact -AdditionalCatalogPath $AdditionalPath).Count | Should -Be 1
        @(Find-KeldorAcronym literal -Exact -AdditionalCatalogPath $AdditionalPath).Count | Should -Be 0
    }

    It 'supports pipeline input' {
        $Result = @('ZZTEST', 'API') | Find-KeldorAcronym -Exact -AdditionalCatalogPath $AdditionalPath
        $Result.Acronym | Should -Contain 'ZZTEST'
        $Result.Acronym | Should -Contain 'API'
    }

    It 'deduplicates complete records and preserves alternate meanings' {
        $Result = @(Find-KeldorAcronym API -Exact -AdditionalCatalogPath $AdditionalPath)
        @($Result | Where-Object Meaning -EQ 'Application Programming Interface').Count | Should -Be 1
        @($Result | Where-Object Meaning -EQ 'Alternate Program Interface').Count | Should -Be 1
    }

    It 'throws actionable errors for missing and malformed catalogs' {
        { Find-KeldorAcronym x -AdditionalCatalogPath (Join-Path $TestDrive 'missing.json') } |
            Should -Throw '*not found*'
        $BadPath = Join-Path $TestDrive 'bad.json'
        Set-Content -LiteralPath $BadPath -Value '{bad'
        { Find-KeldorAcronym x -AdditionalCatalogPath $BadPath } | Should -Throw "*$BadPath*"
    }

    It 'returns no objects for a normal no-match' {
        @(Find-KeldorAcronym 'definitely-no-such-keldor-value').Count | Should -Be 0
    }
}

Describe 'Get-KeldorAcronym' {
    BeforeEach {
        $OnlyPath = Join-Path $TestDrive 'only.json'
        Write-TestAcronymCatalog -Path $OnlyPath -Record @(
            (New-TestAcronymRecord -Acronym 'ONE' -Meaning 'First' -Category 'Alpha'),
            (New-TestAcronymRecord -Acronym 'TWO' -Meaning 'Second' -Category 'Beta'),
            (New-TestAcronymRecord -Acronym 'ONE' -Meaning 'Other' -Category 'Beta')
        )
    }

    It 'returns all records by default and with All' {
        @(Get-KeldorAcronym).Count | Should -BeGreaterThan 100
        @(Get-KeldorAcronym -All).Count | Should -Be @(Get-KeldorAcronym).Count
    }

    It 'filters multiple acronyms and categories with AND/OR semantics' {
        $Result = @(Get-KeldorAcronym -Acronym ONE, TWO -Category Beta `
                -AdditionalCatalogPath $OnlyPath -ExcludeKeldorCatalog)
        $Result.Count | Should -Be 2
        @($Result.Category | Select-Object -Unique) | Should -Be @('Beta')
    }

    It 'supports acronym pipeline input and its alias' {
        $Result = @('ONE', 'TWO') | Get-KDAcronym -AdditionalCatalogPath $OnlyPath -ExcludeKeldorCatalog
        @($Result).Count | Should -Be 3
    }

    It 'loads only additional catalogs when requested' {
        $Result = @(Get-KeldorAcronym -AdditionalCatalogPath $OnlyPath -ExcludeKeldorCatalog)
        $Result.Count | Should -Be 3
        $Result.Acronym | Should -Not -Contain 'DOJ'
    }

    It 'rejects exclusion without an additional catalog' {
        { Get-KeldorAcronym -ExcludeKeldorCatalog } | Should -Throw '*requires*'
    }

    It 'supports ordinary counting and grouping' {
        $Result = @(Get-KeldorAcronym -AdditionalCatalogPath $OnlyPath -ExcludeKeldorCatalog)
        @($Result | Select-Object -ExpandProperty Acronym -Unique).Count | Should -Be 2
        @($Result | Group-Object Category).Count | Should -Be 2
    }
}

Describe 'Export-KeldorAcronym' {
    BeforeEach {
        $CatalogPath = Join-Path $TestDrive 'export-source.json'
        Write-TestAcronymCatalog -Path $CatalogPath -Record @(
            (New-TestAcronymRecord -Acronym 'A|B' -Meaning '<Alpha & Beta>' -Category 'Testing' -Notes "line 1`nline 2")
        )
    }

    It 'exports each supported inferred format with escaped content' -ForEach @(
        @{ Extension = 'json'; Pattern = '"Acronym": "A\|B"' }
        @{ Extension = 'csv'; Pattern = '"A\|B"' }
        @{ Extension = 'md'; Pattern = 'A\\\|B' }
        @{ Extension = 'html'; Pattern = '&lt;Alpha &amp; Beta&gt;' }
    ) {
        $OutputPath = Join-Path $TestDrive "output.$Extension"
        Get-KeldorAcronym -AdditionalCatalogPath $CatalogPath -ExcludeKeldorCatalog |
            Export-KeldorAcronym -Path $OutputPath
        (Get-Content -LiteralPath $OutputPath -Raw) | Should -Match $Pattern
    }

    It 'supports explicit format and direct filtering' {
        $OutputPath = Join-Path $TestDrive 'output.data'
        Export-KeldorAcronym -Path $OutputPath -Format Json -Acronym API
        @((Get-Content $OutputPath -Raw | ConvertFrom-Json)).Acronym | Should -Contain 'API'
    }

    It 'supports additional catalogs, aliases, and PassThru' {
        $OutputPath = Join-Path $TestDrive "passthru-$([guid]::NewGuid()).json"
        $Result = Export-KDAcronym -Path $OutputPath -Format Json `
            -AdditionalCatalogPath $CatalogPath -Acronym 'A|B' -PassThru
        @($Result).Count | Should -Be 1
    }

    It 'protects existing files unless Force is used' {
        $OutputPath = Join-Path $TestDrive 'output.json'
        Set-Content $OutputPath 'original'
        { Export-KeldorAcronym -Path $OutputPath } | Should -Throw '*already exists*'
        { Export-KeldorAcronym -Path $OutputPath -Force } | Should -Not -Throw
    }

    It 'honors WhatIf and produces deterministic output' {
        $OutputPath = Join-Path $TestDrive 'whatif.json'
        Export-KeldorAcronym -Path $OutputPath -WhatIf
        Test-Path $OutputPath | Should -BeFalse

        $FirstPath = Join-Path $TestDrive 'first.json'
        $SecondPath = Join-Path $TestDrive 'second.json'
        Export-KeldorAcronym -Path $FirstPath -Acronym API
        Export-KeldorAcronym -Path $SecondPath -Acronym API
        (Get-Content $FirstPath -Raw) | Should -BeExactly (Get-Content $SecondPath -Raw)
    }
}
