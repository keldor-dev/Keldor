function Get-KeldorAcronymCatalog {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter()]
        [string[]]$AdditionalCatalogPath = @(),

        [Parameter()]
        [switch]$ExcludeKeldorCatalog
    )

    $CatalogPaths = @()
    if (-not $ExcludeKeldorCatalog) {
        $CatalogPaths += Join-Path -Path $script:KeldorModuleRoot -ChildPath 'Resources/Acronyms.json'
    }
    $CatalogPaths += $AdditionalCatalogPath

    if ($CatalogPaths.Count -eq 0) {
        throw 'No acronym catalog was selected.'
    }

    $SeenRecords = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    $Records = foreach ($CatalogPath in $CatalogPaths) {
        if ([string]::IsNullOrWhiteSpace($CatalogPath)) {
            throw 'An acronym catalog path cannot be empty.'
        }

        try {
            $ResolvedPath = (Resolve-Path -LiteralPath $CatalogPath -ErrorAction Stop).Path
        } catch {
            throw "Acronym catalog was not found: '$CatalogPath'."
        }

        if (-not (Test-Path -LiteralPath $ResolvedPath -PathType Leaf)) {
            throw "Acronym catalog path is not a file: '$ResolvedPath'."
        }

        try {
            $RawContent = Get-Content -LiteralPath $ResolvedPath -Raw -ErrorAction Stop
            $ParsedCatalog = ConvertFrom-Json -InputObject $RawContent -ErrorAction Stop
        } catch {
            throw "Unable to read acronym catalog '$ResolvedPath'. $($_.Exception.Message)"
        }

        $CatalogRecords = @()
        if ($null -ne $ParsedCatalog) {
            $CatalogRecords = @($ParsedCatalog)
        }

        foreach ($Record in $CatalogRecords) {
            if ($null -eq $Record) {
                throw "Acronym catalog '$ResolvedPath' contains a null record."
            }

            $PropertyNames = @($Record.PSObject.Properties | Select-Object -ExpandProperty Name)
            foreach ($RequiredProperty in @('Acronym', 'Meaning', 'Category', 'Notes')) {
                if ($PropertyNames -notcontains $RequiredProperty) {
                    throw "Acronym catalog '$ResolvedPath' contains a record without required property '$RequiredProperty'."
                }
            }

            $NormalizedRecord = [PSCustomObject][ordered]@{
                Acronym  = [string]$Record.Acronym
                Meaning  = [string]$Record.Meaning
                Category = [string]$Record.Category
                Notes    = [string]$Record.Notes
            }
            $Key = '{0}{4}{1}{4}{2}{4}{3}' -f $NormalizedRecord.Acronym,
            $NormalizedRecord.Meaning,
            $NormalizedRecord.Category,
            $NormalizedRecord.Notes,
            [char]0x1F

            if ($SeenRecords.Add($Key)) {
                $NormalizedRecord
            }
        }
    }

    @($Records)
}
