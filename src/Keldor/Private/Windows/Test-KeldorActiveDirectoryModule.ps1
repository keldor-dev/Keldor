function Test-KeldorActiveDirectoryModule {
<#
.SYNOPSIS
    Tests whether the ActiveDirectory module is available.

.DESCRIPTION
    Detects whether the ActiveDirectory module is installed and optionally imports it.

.PARAMETER Import
    Imports the ActiveDirectory module when it is available.

.PARAMETER AsBoolean
    Returns only true or false instead of a status object.

.PARAMETER Quiet
    Suppresses warning messages.

.OUTPUTS
    System.Boolean
    System.Management.Automation.PSCustomObject

.LINK
    https://docs.keldor.dev/powershell/keldor/Test-KeldorActiveDirectoryModule
#>

    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Import,

        [Parameter()]
        [switch]$AsBoolean,

        [Parameter()]
        [switch]$Quiet
    )

    $available = $false
    $imported = $false
    $message = $null

    try {
        $module = Get-Module -ListAvailable -Name ActiveDirectory | Select-Object -First 1
        $available = ($null -ne $module)

        if ($available -and $Import) {
            Import-Module ActiveDirectory -ErrorAction Stop
            $imported = $true
        }

        if ($available) {
            $message = 'ActiveDirectory module is available.'
        }
        else {
            $message = 'ActiveDirectory module is not installed or is not available in PSModulePath.'
        }
    }
    catch {
        $available = $false
        $imported = $false
        $message = "ActiveDirectory module could not be imported. $($_.Exception.Message)"
    }

    if ((!$available -or ($Import -and !$imported)) -and !$Quiet) {
        Write-Warning $message
    }

    if ($AsBoolean) {
        return ($available -and (!$Import -or $imported))
    }

    [PSCustomObject]@{
        Name = 'ActiveDirectory'
        Available = $available
        Imported = $imported
        Message = $message
    }
}
