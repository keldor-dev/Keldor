function Test-Online {
    <#
.SYNOPSIS
    Tests Online.

.DESCRIPTION
    Tests Online.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Test-Online
    Runs Test-Online.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Test-Online
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Test-Online')]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    $i = 0
    $number = $ComputerName.length
    foreach ($comp in $ComputerName) {
        if ($number -gt "1") {
            $i++
            $amount = ($i / $number)
            $perc1 = $amount.ToString("P")
            Write-Progress -Activity "Testing whether computers are online or offline. Currently checking $comp" -Status "Computer $i of $number. Percent complete:  $perc1" -PercentComplete (($i / $ComputerName.length) * 100)
        }#if length
        try {
            $testcon = Test-Connection -ComputerName $comp -Count 3 -ErrorAction Stop
            if ($testcon) {
                $status = "Online"
            }#if test
            else {
                $status = "Offline"
            }#else
        }#try
        catch [System.Net.NetworkInformation.PingException] {
            $status = "Comm error"
        }#catch
        catch [System.Management.Automation.InvocationInfo] {
            $status = "Comm error"
        } catch {
            $status = "Comm error"
        }
        [PSCustomObject]@{
            Name   = $comp
            Status = $status
        }#newobject
    }#foreach computer
}
