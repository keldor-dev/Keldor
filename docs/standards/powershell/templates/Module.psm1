$script:ModuleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

foreach ($Path in @(
        (Join-Path -Path $script:ModuleRoot -ChildPath 'Private'),
        (Join-Path -Path $script:ModuleRoot -ChildPath 'Public')
    )) {
    if (Test-Path -Path $Path) {
        Get-ChildItem -Path $Path -Filter '*.ps1' -Recurse |
            Where-Object { -not $_.PSIsContainer } |
            ForEach-Object {
                . $_.FullName
            }
    }
}

$PublicPath = Join-Path -Path $script:ModuleRoot -ChildPath 'Public'

if (Test-Path -Path $PublicPath) {
    $PublicCommands = Get-ChildItem -Path $PublicPath -Filter '*.ps1' -Recurse |
        Where-Object { -not $_.PSIsContainer } |
        Select-Object -ExpandProperty BaseName

    Export-ModuleMember -Function $PublicCommands
}
