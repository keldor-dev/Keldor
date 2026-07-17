function ConvertFrom-KeldorOsRelease {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Content
    )

    $values = [ordered]@{}
    foreach ($line in $Content -split "`r?`n") {
        $trimmedLine = $line.Trim()
        if (!$trimmedLine -or $trimmedLine.StartsWith('#')) {
            continue
        }

        if ($trimmedLine -notmatch '^([A-Z0-9_]+)\s*=\s*(.*)$') {
            continue
        }

        $name = $matches[1]
        $rawValue = $matches[2].Trim()
        $quote = $null
        if (
            $rawValue.Length -ge 2 -and
            ($rawValue[0] -eq '"' -or $rawValue[0] -eq "'") -and
            $rawValue[$rawValue.Length - 1] -eq $rawValue[0]
        ) {
            $quote = $rawValue[0]
            $rawValue = $rawValue.Substring(1, $rawValue.Length - 2)
        }

        if ($quote -eq "'") {
            $value = $rawValue
        } else {
            $builder = New-Object System.Text.StringBuilder
            for ($index = 0; $index -lt $rawValue.Length; $index++) {
                $character = $rawValue[$index]
                if ($character -eq '\' -and $index + 1 -lt $rawValue.Length) {
                    $nextCharacter = $rawValue[$index + 1]
                    if ($nextCharacter -in @('\', '"', '$', '``')) {
                        [void]$builder.Append($nextCharacter)
                        $index++
                        continue
                    }
                }
                [void]$builder.Append($character)
            }
            $value = $builder.ToString()
        }

        $values[$name] = $value
    }

    [pscustomobject]$values
}
