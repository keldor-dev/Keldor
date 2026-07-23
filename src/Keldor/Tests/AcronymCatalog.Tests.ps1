BeforeAll {
    $CatalogPath = Join-Path -Path $PSScriptRoot -ChildPath '../Resources/Acronyms.json'
    $CatalogText = Get-Content -LiteralPath $CatalogPath -Raw -ErrorAction Stop
    $Catalog = @($CatalogText | ConvertFrom-Json -ErrorAction Stop)
    $RequiredProperties = @('Acronym', 'Meaning', 'Category', 'Notes')
    $ApprovedCategories = @(
        'Business and Program Management'
        'Cloud'
        'Cybersecurity'
        'Development and DevOps'
        'EOIR and Immigration'
        'General'
        'Government'
        'Identity and Access Management'
        'Information Technology'
        'Infrastructure'
        'Networking'
    )
}

Describe 'Acronym catalog quality' {
    It 'is valid JSON encoded as UTF-8 without a BOM' {
        { $CatalogText | ConvertFrom-Json -ErrorAction Stop } | Should -Not -Throw

        $Bytes = [System.IO.File]::ReadAllBytes($CatalogPath)
        $HasUtf8Bom = (
            $Bytes.Length -ge 3 -and
            $Bytes[0] -eq 0xEF -and
            $Bytes[1] -eq 0xBB -and
            $Bytes[2] -eq 0xBF
        )
        $HasUtf8Bom | Should -BeFalse
    }

    It 'uses exactly the required properties in canonical order' {
        $Invalid = foreach ($Record in $Catalog) {
            $PropertyNames = @($Record.PSObject.Properties.Name)
            $PropertyDifference = @(Compare-Object `
                    -ReferenceObject $RequiredProperties `
                    -DifferenceObject $PropertyNames `
                    -SyncWindow 0)
            if ($PropertyNames.Count -ne $RequiredProperties.Count -or $PropertyDifference.Count -gt 0) {
                $Record
            }
        }

        @($Invalid) | Should -BeNullOrEmpty
    }

    It 'contains no null or blank required values' {
        $Invalid = foreach ($Record in $Catalog) {
            foreach ($Property in $RequiredProperties) {
                if ($null -eq $Record.$Property -or
                    ($Property -ne 'Notes' -and [string]::IsNullOrWhiteSpace([string]$Record.$Property))) {
                    $Record
                    break
                }
            }
        }

        @($Invalid) | Should -BeNullOrEmpty
    }

    It 'uses only approved categories' {
        $Invalid = @($Catalog | Where-Object { $_.Category -notin $ApprovedCategories })
        $Invalid | Should -BeNullOrEmpty
    }

    It 'has no exact duplicates or repeated acronym-and-meaning pairs' {
        $ExactDuplicates = @($Catalog |
                Group-Object {
                    '{0}|{1}|{2}|{3}' -f `
                        $_.Acronym.ToLowerInvariant(),
                    $_.Meaning.ToLowerInvariant(),
                    $_.Category.ToLowerInvariant(),
                    $_.Notes.ToLowerInvariant()
                } |
                Where-Object Count -GT 1)
        $PairDuplicates = @($Catalog |
                Group-Object {
                    '{0}|{1}' -f $_.Acronym.ToLowerInvariant(), $_.Meaning.ToLowerInvariant()
                } |
                Where-Object Count -GT 1)

        $ExactDuplicates | Should -BeNullOrEmpty
        $PairDuplicates | Should -BeNullOrEmpty
    }

    It 'is sorted by acronym, meaning, category, and notes' {
        $Sorted = @($Catalog | Sort-Object -Property Acronym, Meaning, Category, Notes)
        $ActualKeys = @($Catalog | ForEach-Object {
                '{0}|{1}|{2}|{3}' -f $_.Acronym, $_.Meaning, $_.Category, $_.Notes
            })
        $ExpectedKeys = @($Sorted | ForEach-Object {
                '{0}|{1}|{2}|{3}' -f $_.Acronym, $_.Meaning, $_.Category, $_.Notes
            })

        $ActualKeys | Should -BeExactly $ExpectedKeys
    }

    It 'contains no leading, trailing, or duplicate spaces' {
        $Invalid = foreach ($Record in $Catalog) {
            foreach ($Property in $RequiredProperties) {
                $Value = [string]$Record.$Property
                if ($Value -ne $Value.Trim() -or $Value -match ' {2,}') {
                    $Record
                    break
                }
            }
        }

        @($Invalid) | Should -BeNullOrEmpty
    }

    It 'rejects known wording, casing, encoding, and concatenation defects' {
        $Invalid = @($Catalog | Where-Object {
                $_.Meaning -cmatch '\b(DataBase|FireWall|HyperVisor|NameSpace)\b' -or
                $_.Meaning -match '^stands for\s+' -or
                $_.Acronym -match '[ÃÂ]|\uFFFD|â€' -or
                $_.Meaning -match '[ÃÂ]|\uFFFD|â€' -or
                $_.Meaning -match '\([A-Z0-9&/-]{2,}\)[A-Z0-9&/-]{2,}\s*[-–—]'
            })

        $Invalid | Should -BeNullOrEmpty
    }
}
