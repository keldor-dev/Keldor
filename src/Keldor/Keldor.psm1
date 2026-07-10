#Requires -Version 3

function Get-KeldorScriptFiles {
    param(
        [Parameter(Mandatory=$true)]
        [string]$RelativePath
    )

    $path = Join-Path -Path $PSScriptRoot -ChildPath $RelativePath
    if (!(Test-Path -Path $path)) {
        return @()
    }

    @(Get-ChildItem -Path $path -Recurse -ErrorAction SilentlyContinue | Where-Object {!$_.PSIsContainer -and $_.Extension -ieq '.ps1'})
}

$PublicFunctions = @()

$CommonFolders = @(
    @{ Path = 'Private/Common'; Public = $false }
    @{ Path = 'Public/Common'; Public = $true }
)

$PlatformFolders = @{
    Windows = @(
        @{ Path = 'Private/Windows'; Public = $false }
        @{ Path = 'Public/Windows'; Public = $true }
    )
    macOS = @(
        @{ Path = 'Private/macOS'; Public = $false }
        @{ Path = 'Public/macOS'; Public = $true }
    )
    Linux = @(
        @{ Path = 'Private/Linux'; Public = $false }
        @{ Path = 'Public/Linux'; Public = $true }
    )
}

foreach ($folder in $CommonFolders) {
    $files = Get-KeldorScriptFiles -RelativePath $folder.Path
    foreach ($file in $files) {
        try {
            . $file.FullName
        }
        catch {
            Write-Error -Message "Failed to import script file $($file.FullName): $_"
        }
    }

    if ($folder.Public) {
        $PublicFunctions += $files
    }
}

$KeldorPlatform = Get-KeldorPlatform

if ($PlatformFolders.ContainsKey($KeldorPlatform)) {
    foreach ($folder in $PlatformFolders[$KeldorPlatform]) {
        $files = Get-KeldorScriptFiles -RelativePath $folder.Path
        foreach ($file in $files) {
            try {
                . $file.FullName
            }
            catch {
                Write-Error -Message "Failed to import script file $($file.FullName): $_"
            }
        }

        if ($folder.Public) {
            $PublicFunctions += $files
        }
    }
}
else {
    Write-Warning "Keldor could not determine the current platform. Only common functions were loaded."
}

$PublicFunctionNames = @($PublicFunctions | Select-Object -ExpandProperty BaseName -Unique)
$PublicAliasNames = @(
    Get-Alias -Name 'Get-KDSecret' -ErrorAction SilentlyContinue |
        Where-Object { $PublicFunctionNames -contains $_.Definition } |
        Select-Object -ExpandProperty Name -Unique
)
Export-ModuleMember -Function $PublicFunctionNames -Alias $PublicAliasNames
