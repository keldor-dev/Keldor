function Get-KeldorLinuxOsRelease {
    [CmdletBinding()]
    param(
        [string[]]$Path = @('/etc/os-release', '/usr/lib/os-release')
    )

    foreach ($candidatePath in $Path) {
        if (!(Test-Path -LiteralPath $candidatePath -PathType Leaf)) {
            continue
        }

        $data = ConvertFrom-KeldorOsRelease -Content (Get-Content -LiteralPath $candidatePath -Raw -ErrorAction Stop)
        return [pscustomobject]@{
            Data       = $data
            SourcePath = $candidatePath
        }
    }

    $null
}
