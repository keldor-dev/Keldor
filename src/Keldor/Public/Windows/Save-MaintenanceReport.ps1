function Save-MaintenanceReport {
    <#
.SYNOPSIS
    Saves Maintenance Report.

.DESCRIPTION
    Saves Maintenance Report.

.PARAMETER Days
    Specifies the Days value.

.EXAMPLE
    Save-MaintenanceReport
    Runs Save-MaintenanceReport.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Save-MaintenanceReport
#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Save-MaintenanceReport')]
    param (
        [Parameter(
            Mandatory = $false,
            Position = 0
        )]
        [int32]$Days = ((Get-Date -Format yyyyMMdd) - ((Get-Date -Format yyyyMMdd).Substring(0, 6) + "01"))
    )

    $UHPath = ($Global:KeldorConfig).UHPath
    $dt = Get-Date -Format yyyyMMdd
    $sp = $UHPath + "\" + $dt + "_MaintenanceReport.csv"
    $stime = (Get-Date) - (New-TimeSpan -Day $Days)
    $info = Get-ChildItem $UHPath | Where-Object { $_.LastWriteTime -gt $stime -and $_.Name -notlike "*MaintenanceReport.csv" } | Select-Object FullName -ExpandProperty FullName
    $finfo = Import-Csv ($info)
    $finfo | Select-Object Date, ComputerName, KB, Result, Title, Description, Category, ClientApplicationID, SupportUrl | Where-Object { $_.Date -gt $stime } | Sort-Object Date, ComputerName -Descending | Export-Csv $sp -NoTypeInformation
}
