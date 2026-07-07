function Update-VisioStencils {
<#
.SYNOPSIS
    Updates Visio Stencils.

.DESCRIPTION
    Updates Visio Stencils.

.EXAMPLE
    Update-VisioStencils
    Runs Update-VisioStencils.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Update-VisioStencils
#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSUseSingularNouns",
        "",
        Justification = "Expresses exactly what the function does."
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Update-VisioStencils')]
    [Alias('Copy-VisioStencils','Get-VisioStencils')]
    param()

    $vspath = ($Global:KeldorConfig).Stencils
    $rpath = [System.Environment]::GetFolderPath("MyDocuments") + "\My Shapes"

    if (Test-Path $rpath) {
        $confirmation = Read-Host "Are you sure you want to overwrite the files in $rpath with files in $vspath`? `nPress y for yes and then press enter. To cancel enter any other value then press enter."
        if ($confirmation -eq 'y') {
            robocopy $vspath $rpath /mir /mt:4 /r:3 /w:15 /njh /njs
        }
    }
    else {
        robocopy $vspath $rpath /mir /mt:4 /r:3 /w:15 /njh /njs
    }
}
