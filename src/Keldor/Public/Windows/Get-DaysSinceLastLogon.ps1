function Get-DaysSinceLastLogon {
    <#
.SYNOPSIS
    Gets Days Since Last Logon.

.DESCRIPTION
    Gets Days Since Last Logon.

.PARAMETER Name
    Specifies the Name value.

.EXAMPLE
    Get-DaysSinceLastLogon
    Runs Get-DaysSinceLastLogon.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-DaysSinceLastLogon
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-DaysSinceLastLogon')]
    param (
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('User', 'SamAccountName', 'Computer', 'ComputerName', 'Username')]
        [string[]]$Name = "$env:USERNAME"
    )
    begin {
        $sd = Get-Date
    }
    process {
        foreach ($obj in $Name) {
            try { $record = Get-ADUser $obj -Properties LastLogonDate }
            catch {
                $nobj = $obj + "$"
                $record = Get-ADComputer $nobj -Properties LastLogonDate
            }
            $name = $record.Name
            $LLD = $record.LastLogonDate
            $sam = $record.SamAccountName
            try {
                $dsll = [math]::Round(( - (New-TimeSpan -Start $sd -End $LLD)).TotalDays)
            } catch {
                $dsll = "NA"
            }

            [PSCustomObject]@{
                Name               = $obj
                UserName           = $obj
                DaysSinceLastLogon = $dsll
                SamAccountName     = $sam
                CheckedAt          = $sd
            }#new object
        }
    }
    end {}
}
