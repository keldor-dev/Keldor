function Export-KeldorAcronym {
    <#
    .SYNOPSIS
        Exports acronym records to JSON, CSV, Markdown, or HTML.
    .DESCRIPTION
        Exports pipeline records or records retrieved from Keldor catalogs. The format can be selected explicitly or
        inferred from the destination extension. Existing files require Force.
    .PARAMETER Path
        Destination file path.
    .PARAMETER Format
        Output format: Json, Csv, Markdown, or Html.
    .PARAMETER InputObject
        Acronym records received from the pipeline.
    .PARAMETER Acronym
        One or more exact acronym filters for direct retrieval.
    .PARAMETER Category
        One or more exact category filters for direct retrieval.
    .PARAMETER AdditionalCatalogPath
        One or more supplemental acronym JSON files.
    .PARAMETER Force
        Allows replacement of an existing destination file.
    .PARAMETER PassThru
        Returns the exported acronym records.
    .EXAMPLE
        Export-KeldorAcronym -Path ./Acronyms.json
    .EXAMPLE
        Get-KeldorAcronym -Category Government | Export-KeldorAcronym -Path ./Government.md
    .EXAMPLE
        Find-KeldorAcronym Azure | Export-KDAcronym -Path ./Azure.csv -Force
    .INPUTS
        System.Management.Automation.PSCustomObject
    .OUTPUTS
        System.Management.Automation.PSCustomObject when PassThru is specified.
    .LINK
        https://docs.keldor.dev/powershell/keldor/Export-KeldorAcronym
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'Direct',
        SupportsShouldProcess,
        ConfirmImpact = 'Low',
        HelpUri = 'https://docs.keldor.dev/powershell/keldor/Export-KeldorAcronym'
    )]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter()]
        [ValidateSet('Json', 'Csv', 'Markdown', 'Html')]
        [string]$Format,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Pipeline')]
        [ValidateNotNull()]
        [object]$InputObject,

        [Parameter(ParameterSetName = 'Direct')]
        [string[]]$Acronym,

        [Parameter(ParameterSetName = 'Direct')]
        [string[]]$Category,

        [Parameter(ParameterSetName = 'Direct')]
        [string[]]$AdditionalCatalogPath = @(),

        [Parameter()]
        [switch]$Force,

        [Parameter()]
        [switch]$PassThru
    )

    begin {
        $PipelineRecords = @()
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Pipeline') {
            $PipelineRecords += $InputObject
        }
    }

    end {
        if (-not $Format) {
            $Extension = [System.IO.Path]::GetExtension($Path).ToLowerInvariant()
            $Format = switch ($Extension) {
                '.json' { 'Json' }
                '.csv' { 'Csv' }
                '.md' { 'Markdown' }
                '.markdown' { 'Markdown' }
                '.html' { 'Html' }
                '.htm' { 'Html' }
                default { throw "Unable to infer export format from extension '$Extension'. Specify -Format." }
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'Pipeline') {
            $Records = @($PipelineRecords | Select-Object -Property Acronym, Meaning, Category, Notes |
                    Sort-Object -Property Category, Acronym, Meaning)
        } else {
            $Records = @(Get-KeldorAcronym `
                    -Acronym $Acronym `
                    -Category $Category `
                    -AdditionalCatalogPath $AdditionalCatalogPath)
        }

        if ((Test-Path -LiteralPath $Path) -and -not $Force) {
            throw "The export file already exists: '$Path'. Use -Force to replace it."
        }

        $ParentPath = Split-Path -Path ([System.IO.Path]::GetFullPath($Path)) -Parent
        if (-not (Test-Path -LiteralPath $ParentPath -PathType Container)) {
            throw "The export directory does not exist: '$ParentPath'."
        }

        switch ($Format) {
            'Json' {
                $Content = ConvertTo-Json -InputObject @($Records) -Depth 10
            }
            'Csv' {
                $Content = (@($Records | ConvertTo-Csv -NoTypeInformation) -join "`n")
            }
            'Markdown' {
                $Lines = @('| Acronym | Meaning | Category | Notes |', '|---|---|---|---|')
                foreach ($Record in $Records) {
                    $Values = foreach ($Property in @('Acronym', 'Meaning', 'Category', 'Notes')) {
                        ([string]$Record.$Property).Replace('|', '\|').Replace("`r`n", '<br>').Replace("`n", '<br>')
                    }
                    $Lines += '| {0} | {1} | {2} | {3} |' -f $Values
                }
                $Content = $Lines -join "`n"
            }
            'Html' {
                $Encode = [System.Net.WebUtility]
                $Rows = foreach ($Record in $Records) {
                    '<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td></tr>' -f
                    $Encode::HtmlEncode([string]$Record.Acronym),
                    $Encode::HtmlEncode([string]$Record.Meaning),
                    $Encode::HtmlEncode([string]$Record.Category),
                    $Encode::HtmlEncode([string]$Record.Notes)
                }
                $Content = @(
                    '<!DOCTYPE html>'
                    '<html><head><meta charset="utf-8"><title>Keldor Acronyms</title></head><body>'
                    '<h1>Keldor Acronyms</h1>'
                    '<table><thead><tr><th>Acronym</th><th>Meaning</th><th>Category</th><th>Notes</th></tr></thead><tbody>'
                    $Rows
                    '</tbody></table></body></html>'
                ) -join "`n"
            }
        }

        if ($PSCmdlet.ShouldProcess($Path, "Export $($Records.Count) acronym record(s) as $Format")) {
            [System.IO.File]::WriteAllText(
                [System.IO.Path]::GetFullPath($Path),
                $Content + "`n",
                (New-Object System.Text.UTF8Encoding($false))
            )

            if ($PassThru) {
                $Records
            }
        }
    }
}

Set-Alias -Name Export-KDAcronym -Value Export-KeldorAcronym
