function Show-FederalHoliday {
<#
.SYNOPSIS
    Shows Federal Holiday.

.DESCRIPTION
    Shows Federal Holiday.

.PARAMETER Name
    Specifies the Name value.

.PARAMETER Year
    Specifies the Year value.

.PARAMETER AllYears
    Specifies whether to enable the All Years option.

.EXAMPLE
    Show-FederalHoliday
    Runs Show-FederalHoliday.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Show-FederalHoliday
#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Show-FederalHoliday')]
    [Alias('Get-FederalHoliday')]
    param(
        [Parameter(Mandatory=$false)]
        [string[]]$Name,

        [Parameter(Mandatory=$false)]
        [int32]$Year,

        [Parameter(Mandatory=$false)]
        [switch]$AllYears
    )

    $holidays = ($Global:KeldorConfig).Holidays
    $fyear = $holidays.Year | Select-Object -First 1
    $lyear = $holidays.Year | Select-Object -Last 1
    $cyear = (Get-Date).Year

    Write-Verbose "Year is set to: $Year"

    if ([string]::IsNullOrWhiteSpace($Year) -or $Year -eq 0) {
        Write-Verbose "Year is null, empty, or set to 0. Setting year to $cyear"
        $Year = $cyear
    }
    else {
        Write-Verbose "Year is populated."
        if ($Year -ge $fyear -and $Year -le $lyear) {
            #do nothing
        }
        else {
            $obj = "Year $Year is not between $fyear and $lyear."
            Write-Error "Year entered is not valid. See details below for valid years." -TargetObject $obj -ErrorAction Stop
        }
    }

    if ([string]::IsNullOrWhiteSpace($Name)) {
        if ($AllYears) {
            $holidays | Select-Object Name,Year,Date,DayOfWeek | Sort-Object Date
        }
        else {
            $holidays | Where-Object {$_.Year -eq $Year} | Select-Object Name,Date,DayOfWeek | Sort-Object Date
        }
    }#if no name specified
    else {
        foreach ($hol in $Name) {
            if ($AllYears) {
                $holidays | Where-Object {$_.Name -match $hol} | Select-Object Name,Year,Date,DayOfWeek
            }#if all years
            else {
                $holidays | Where-Object {$_.Year -eq $Year -and $_.Name -match $hol} | Select-Object Name,Date,DayOfWeek
            }#if specific year
        }#for each name entered
    }#if a name is specified
}
