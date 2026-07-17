function ConvertTo-KeldorVersion {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [object]$Value
    )

    if ($null -eq $Value) { return $null }
    if ($Value -is [version]) { return $Value }

    try {
        [version]$Value.ToString()
    } catch {
        $null
    }
}
