#Requires -Version 5.1

$script:KeldorModuleRoot = $PSScriptRoot

function New-KeldorLoadException {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$File,

        [Parameter(Mandatory = $true)]
        [System.Exception]$InnerException
    )

    $message = "Keldor failed to load required script file '$($File.FullName)'."
    New-Object System.InvalidOperationException $message, $InnerException
}

function Get-KeldorScriptFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RelativePath,

        [string[]]$ExcludeBaseName = @()
    )

    $path = Join-Path -Path $script:KeldorModuleRoot -ChildPath $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        return @()
    }

    @(
        Get-ChildItem -LiteralPath $path -Filter '*.ps1' -File -ErrorAction Stop |
            Where-Object {
                $_.Name -notmatch '^[.~]' -and
                $ExcludeBaseName -notcontains $_.BaseName
            } |
            Sort-Object -Property FullName
    )
}

$runtimeCheckPath = Join-Path -Path $script:KeldorModuleRoot -ChildPath (
    'Private/Common/Test-KeldorPowerShellRuntime.ps1'
)
$bootstrapPlatformPath = Join-Path -Path $script:KeldorModuleRoot -ChildPath (
    'Private/Common/Get-KeldorBootstrapPlatform.ps1'
)

$runtimeCheckFile = Get-Item -LiteralPath $runtimeCheckPath -ErrorAction Stop
try {
    . $runtimeCheckFile.FullName
} catch {
    throw (New-KeldorLoadException -File $runtimeCheckFile -InnerException $_.Exception)
}
Test-KeldorPowerShellRuntime -Version $PSVersionTable.PSVersion -Edition $PSVersionTable.PSEdition | Out-Null

foreach ($relativePath in @('config.ps1', 'classes.ps1')) {
    $filePath = Join-Path -Path $script:KeldorModuleRoot -ChildPath $relativePath
    $file = Get-Item -LiteralPath $filePath -ErrorAction Stop
    try {
        . $file.FullName
    } catch {
        throw (New-KeldorLoadException -File $file -InnerException $_.Exception)
    }
}

$bootstrapPlatformFile = Get-Item -LiteralPath $bootstrapPlatformPath -ErrorAction Stop
try {
    . $bootstrapPlatformFile.FullName
} catch {
    throw (New-KeldorLoadException -File $bootstrapPlatformFile -InnerException $_.Exception)
}
$script:KeldorPlatform = Get-KeldorBootstrapPlatform

$publicFunctionNames = @()
$bootstrapPrivateNames = @(
    'Get-KeldorBootstrapPlatform'
    'Test-KeldorPowerShellRuntime'
)
$loadGroups = @(
    [pscustomobject]@{
        Path    = 'Private/Common'
        Public  = $false
        Exclude = $bootstrapPrivateNames
    },
    [pscustomobject]@{ Path = "Private/$script:KeldorPlatform"; Public = $false; Exclude = @() },
    [pscustomobject]@{ Path = 'Public/Common'; Public = $true; Exclude = @() },
    [pscustomobject]@{ Path = "Public/$script:KeldorPlatform"; Public = $true; Exclude = @() }
)

foreach ($loadGroup in $loadGroups) {
    foreach ($file in Get-KeldorScriptFile -RelativePath $loadGroup.Path -ExcludeBaseName $loadGroup.Exclude) {
        try {
            . $file.FullName
        } catch {
            throw (New-KeldorLoadException -File $file -InnerException $_.Exception)
        }
        if ($loadGroup.Public) {
            $publicFunctionNames += $file.BaseName
        }
    }
}

$publicFunctionNames = @($publicFunctionNames | Sort-Object -Unique)
$knownPublicAliasNames = @(
    'Get-KDSecret'
    'Set-KDSecret'
    'Remove-KDSecret'
    'Get-KDSecretProvider'
    'Test-KDSecretProvider'
)
$publicAliasNames = @(
    Get-Alias -Name $knownPublicAliasNames -ErrorAction SilentlyContinue |
        Where-Object { $publicFunctionNames -contains $_.Definition } |
        Select-Object -ExpandProperty Name -Unique
)

Export-ModuleMember -Function $publicFunctionNames -Alias $publicAliasNames
