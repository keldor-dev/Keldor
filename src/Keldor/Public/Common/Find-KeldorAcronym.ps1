function Find-KeldorAcronym {
    <#
    .SYNOPSIS
        Searches Keldor acronym catalogs.
    .DESCRIPTION
        Searches acronym, meaning, category, and notes using a case-insensitive literal partial match. Exact mode
        matches only the Acronym property. Additional JSON catalogs can supplement Keldor's bundled catalog.
    .PARAMETER Search
        Literal text to find. This parameter accepts pipeline input and is positional.
    .PARAMETER Exact
        Matches only complete acronym values.
    .PARAMETER AdditionalCatalogPath
        One or more supplemental acronym JSON files.
    .EXAMPLE
        Find-KeldorAcronym DOJ
    .EXAMPLE
        'API', 'DNS' | Find-KDAcronym -Exact
    .EXAMPLE
        Find-KeldorAcronym DAR -AdditionalCatalogPath ./EOIR/Resources/Acronyms.json
    .INPUTS
        System.String
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    .LINK
        https://docs.keldor.dev/powershell/keldor/Find-KeldorAcronym
    #>
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Find-KeldorAcronym')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$Search,

        [Parameter()]
        [switch]$Exact,

        [Parameter()]
        [string[]]$AdditionalCatalogPath = @()
    )

    begin {
        $Catalog = @(Get-KeldorAcronymCatalog -AdditionalCatalogPath $AdditionalCatalogPath)
    }

    process {
        if ($Exact) {
            $Matches = @($Catalog | Where-Object { $_.Acronym -ieq $Search })
        } else {
            $LiteralSearch = [regex]::Escape($Search)
            $Matches = @($Catalog | Where-Object {
                    $_.Acronym -imatch $LiteralSearch -or
                    $_.Meaning -imatch $LiteralSearch -or
                    $_.Category -imatch $LiteralSearch -or
                    $_.Notes -imatch $LiteralSearch
                })
        }

        $Matches | Sort-Object -Property Acronym, Meaning
    }
}

Set-Alias -Name Find-KDAcronym -Value Find-KeldorAcronym
