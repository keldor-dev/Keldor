function Convert-DaysToWorkDay {
<#
.SYNOPSIS
    Converts Days To Work Day.

.DESCRIPTION
    Converts Days To Work Day.

.PARAMETER Days
    Specifies the Days value.

.PARAMETER StartDay
    Specifies the Start Day value.

.EXAMPLE
    Convert-DaysToWorkDay 1
    Example of how to use this cmdlet

.EXAMPLE
    Convert-DaysToWorkDay -1
    Another example of how to use this cmdlet.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Convert-DaysToWorkDay
#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Convert-DaysToWorkDay')]
    param(
        [Parameter(
            HelpMessage = "Enter the amount of days you want to convert. Must an a positive or negative integer (Ex: 1 or -1).",
            Mandatory=$true,
            Position=0
        )]
        [int32]$Days,

        [Parameter(
            HelpMessage = "Must be in the format yyyy-MM-dd.",
            Mandatory=$false,
            Position=1
        )]
        [datetime]$StartDay = (Get-Date).Date
    )

    $holidays = ($Global:KeldorConfig).Holidays.Date

    if ($Days -lt 0) {
        $sub = "sub"
    }
    elseif ($Days -gt 0) {
        $sub = "add"
    }
    else {$sub = "zero"}

    if ($sub -eq "sub") {
        $i = -1
        do {
            $StartDay = $StartDay.AddDays(-1)

            if ($holidays -contains $StartDay) {
                $StartDay = $StartDay.AddDays(-1)
            }

            if ($StartDay.DayOfWeek -match "Sunday") {
                $StartDay = $StartDay.AddDays(-1)
            }

            if ($StartDay.DayOfWeek -match "Saturday") {
                $StartDay = $StartDay.AddDays(-1)
            }

            if ($holidays -contains $StartDay) {
                $StartDay = $StartDay.AddDays(-1)
            }

            $i--
        } until ($i -lt $Days)

        if ($holidays -contains $StartDay) {
            $StartDay = $StartDay.AddDays(-1)
        }

        if ($StartDay.DayOfWeek -match "Sunday") {
            $StartDay = $StartDay.AddDays(-1)
        }

        if ($StartDay.DayOfWeek -match "Saturday") {
            $StartDay = $StartDay.AddDays(-1)
        }

        if ($holidays -contains $StartDay) {
            $StartDay = $StartDay.AddDays(-1)
        }
        $StartDay
    }
    elseif ($sub -eq "add") {
        $i = 1
        do {
            $StartDay = $StartDay.AddDays(1)

            if ($holidays -contains $StartDay) {
                $StartDay = $StartDay.AddDays(1)
            }

            if ($StartDay.DayOfWeek -match "Saturday") {
                $StartDay = $StartDay.AddDays(1)
            }

            if ($StartDay.DayOfWeek -match "Sunday") {
                $StartDay = $StartDay.AddDays(1)
            }

            if ($holidays -contains $StartDay) {
                $StartDay = $StartDay.AddDays(1)
            }

            $i++
        } until ($i -gt $Days)

        if ($holidays -contains $StartDay) {
            $StartDay = $StartDay.AddDays(1)
        }

        if ($StartDay.DayOfWeek -match "Saturday") {
            $StartDay = $StartDay.AddDays(1)
        }

        if ($StartDay.DayOfWeek -match "Sunday") {
            $StartDay = $StartDay.AddDays(1)
        }

        if ($holidays -contains $StartDay) {
            $StartDay = $StartDay.AddDays(1)
        }
        $StartDay
    }
    else {$StartDay}
}
