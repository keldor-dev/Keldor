function Get-KeldorAcronym {
    <#
    .SYNOPSIS
        Retrieves structured acronym records.
    .DESCRIPTION
        Returns all loaded acronym records or filters by exact acronym and category values. Supplemental catalogs are
        deduplicated by complete record while alternate meanings are preserved.
    .PARAMETER Acronym
        One or more exact acronym values. Accepts pipeline input.
    .PARAMETER Category
        One or more exact category values.
    .PARAMETER All
        Explicitly requests every loaded record.
    .PARAMETER AdditionalCatalogPath
        One or more supplemental acronym JSON files.
    .PARAMETER ExcludeKeldorCatalog
        Loads only the supplemental catalogs. Requires AdditionalCatalogPath.
    .EXAMPLE
        Get-KeldorAcronym
    .EXAMPLE
        Get-KeldorAcronym -Category Government
    .EXAMPLE
        Get-KeldorAcronym -AdditionalCatalogPath ./EOIR.json -ExcludeKeldorCatalog
    .INPUTS
        System.String
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    .LINK
        https://docs.keldor.dev/powershell/keldor/Get-KeldorAcronym
    #>
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-KeldorAcronym')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Position = 0, ValueFromPipeline)]
        [string[]]$Acronym,

        [Parameter()]
        [string[]]$Category,

        [Parameter()]
        [switch]$All,

        [Parameter()]
        [string[]]$AdditionalCatalogPath = @(),

        [Parameter()]
        [switch]$ExcludeKeldorCatalog
    )

    begin {
        if ($ExcludeKeldorCatalog -and $AdditionalCatalogPath.Count -eq 0) {
            throw '-ExcludeKeldorCatalog requires -AdditionalCatalogPath.'
        }
        $RequestedAcronyms = @()
    }

    process {
        if ($null -ne $Acronym) {
            $RequestedAcronyms += $Acronym
        }
    }

    end {
        $Catalog = @(Get-KeldorAcronymCatalog `
                -AdditionalCatalogPath $AdditionalCatalogPath `
                -ExcludeKeldorCatalog:$ExcludeKeldorCatalog)

        $Results = @($Catalog | Where-Object {
                $AcronymMatch = $RequestedAcronyms.Count -eq 0
                foreach ($Value in $RequestedAcronyms) {
                    if ($_.Acronym -ieq $Value) {
                        $AcronymMatch = $true
                        break
                    }
                }

                $CategoryMatch = $Category.Count -eq 0
                foreach ($Value in $Category) {
                    if ($_.Category -ieq $Value) {
                        $CategoryMatch = $true
                        break
                    }
                }

                $AcronymMatch -and $CategoryMatch
            })

        $Results | Sort-Object -Property Category, Acronym, Meaning
    }
}

Set-Alias -Name Get-KDAcronym -Value Get-KeldorAcronym
