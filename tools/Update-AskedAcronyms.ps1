[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$catalogPath = Join-Path $PSScriptRoot '../src/Keldor/Resources/Acronyms.json'

$entries = @(
    [pscustomobject]@{
        Acronym = 'DAR'
        Meaning = 'Digital Audio Recording'
        Category = 'EOIR and Immigration'
        Notes = 'EOIR court proceeding recording system.'
    }
    [pscustomobject]@{
        Acronym = 'EOIR'
        Meaning = 'Executive Office for Immigration Review'
        Category = 'Government'
        Notes = 'U.S. Department of Justice component responsible for immigration courts and administrative appeals.'
    }
    [pscustomobject]@{
        Acronym = 'GPG'
        Meaning = 'GNU Privacy Guard'
        Category = 'Cybersecurity'
        Notes = 'GNU implementation of the OpenPGP standard.'
    }
    [pscustomobject]@{
        Acronym = 'HALEY'
        Meaning = 'Home Assistant for Living, Ease, and You'
        Category = 'General'
        Notes = 'Custom Home Assistant voice-assistant name.'
    }
    [pscustomobject]@{
        Acronym = 'JCOTS'
        Meaning = 'Justice Cloud-Optimized Trusted Internet Connection Service'
        Category = 'Government'
        Notes = 'DOJ secure network gateway service.'
    }
    [pscustomobject]@{
        Acronym = 'JMD'
        Meaning = 'Justice Management Division'
        Category = 'Government'
        Notes = 'U.S. Department of Justice management and administrative services component.'
    }
    [pscustomobject]@{
        Acronym = 'PGP'
        Meaning = 'Pretty Good Privacy'
        Category = 'Cybersecurity'
        Notes = 'Encryption and signing system associated with the OpenPGP standard.'
    }
    [pscustomobject]@{
        Acronym = 'SWM'
        Meaning = 'Stormwater Management'
        Category = 'Infrastructure'
        Notes = 'Commonly used for stormwater management facilities.'
    }
)

$catalog = @(Get-Content -LiteralPath $catalogPath -Raw | ConvertFrom-Json)

foreach ($entry in $entries) {
    $exists = $catalog | Where-Object {
        $_.Acronym -eq $entry.Acronym -and $_.Meaning -eq $entry.Meaning
    }

    if (-not $exists) {
        $catalog += $entry
    }
}

$catalog = @($catalog | Sort-Object Acronym, Meaning)
$json = ConvertTo-Json -InputObject $catalog -Depth 10
[System.IO.File]::WriteAllText(
    [System.IO.Path]::GetFullPath($catalogPath),
    $json + [Environment]::NewLine,
    [System.Text.UTF8Encoding]::new($false)
)
