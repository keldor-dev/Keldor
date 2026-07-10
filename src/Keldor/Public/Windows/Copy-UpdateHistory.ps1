function Copy-UpdateHistory {
    <#
.SYNOPSIS
    Copies the UpdateHistory.csv report to the UHPath config item path.

.DESCRIPTION
    Copies the UpdateHistory.csv report created with Save-UpdateHistory to the UHPath config item path for the local computer or remote computers.

.PARAMETER ComputerName
    Specifies the name of one or more computers.

.EXAMPLE
    Copy-UpdateHistory
    Example of how to use this cmdlet to copy the UpdateHistory.csv file for the local computer to the UHPath location.

.EXAMPLE
    Copy-UpdateHistory -ComputerName Server1
    Example of how to use this cmdlet to copy the UpdateHistory.csv file for the remote computer Server1 to the UHPath location.

.OUTPUTS
    System.String

.LINK
    https://docs.keldor.dev/powershell/keldor/Copy-UpdateHistory
#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Copy-UpdateHistory')]
    param(
        [Parameter(
            Mandatory = $false
        )]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    $uhpath = ($Global:KeldorConfig).UHPath
    $i = 0
    $number = $ComputerName.length
    foreach ($Comp in $ComputerName) {
        # Progress Bar
        if ($number -gt "1") {
            $i++
            $amount = ($i / $number)
            $perc1 = $amount.ToString("P")
            Write-Progress -Activity "Copying Update Reports. Current computer: $Comp" -Status "Computer $i of $number. Percent complete:  $perc1" -PercentComplete (($i / $ComputerName.length) * 100)
        }# if length

        if ($Comp -eq $env:COMPUTERNAME) {
            if (Test-Path C:\ProgramData\Keldor\Reports\$Comp`_UpdateHistory.csv) {
                robocopy C:\ProgramData\Keldor\Reports $uhpath *_UpdateHistory.csv /r:3 /w:5 /njh /njs | Out-Null
            } else {
                Write-Error "Report not found. Please use Save-UpdateHistory to create a report."
            }
        } else {
            robocopy \\$Comp\c$\ProgramData\Keldor\Reports $uhpath *_UpdateHistory.csv /r:3 /w:5 /njh /njs | Out-Null
        }
    }
}
