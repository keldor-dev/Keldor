#Requires -Version 5.1

$script:ModuleRoot = $PSScriptRoot

foreach ($Path in @(
        (Join-Path -Path $script:ModuleRoot -ChildPath 'Private'),
        (Join-Path -Path $script:ModuleRoot -ChildPath 'Public')
    )) {
    if (Test-Path -Path $Path) {
        Get-ChildItem -LiteralPath $Path -Filter '*.ps1' -File |
            Sort-Object -Property FullName |
            ForEach-Object {
                . $_.FullName
            }
    }
}

$PublicPath = Join-Path -Path $script:ModuleRoot -ChildPath 'Public'

if (Test-Path -Path $PublicPath) {
    $PublicCommands = Get-ChildItem -LiteralPath $PublicPath -Filter '*.ps1' -File |
        Sort-Object -Property FullName |
        Select-Object -ExpandProperty BaseName

    Export-ModuleMember -Function $PublicCommands
}
