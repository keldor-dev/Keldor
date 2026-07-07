function Get-LockedOutStatus {
<#
.SYNOPSIS
    Gets Locked Out Status.

.DESCRIPTION
    Gets Locked Out Status.

.PARAMETER UserName
    Specifies the UserName value.

.EXAMPLE
    Get-LockedOutStatus
    Runs Get-LockedOutStatus.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-LockedOutStatus
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-LockedOutStatus')]
    Param (
        [Parameter(
            Mandatory=$false,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [Alias('Username','User','SamAccountName')]
        [string[]]$UserName = "$env:USERNAME"
    )
    Begin {
        $cktime = Get-Date -Format t
        if (Test-KeldorActiveDirectoryModule -AsBoolean -Quiet) {
            #ad module is installed
        }
        else {
            Write-Warning "Active Directory module is not installed and is required to run this command."
            break
        }
    }
    Process {
        foreach ($user in $UserName) {
            $usrquery = Get-ADUser $User -properties LockedOut,lockoutTime
            $locked = $usrquery.LockedOut
            $locktime = $usrquery.lockoutTime
            if ($locked -eq $true) {
                [PSCustomObject]@{
                    User = $user
                    Status = "Locked"
                    Date = $locktime
                    CheckTime = $cktime
                }
            }#if
            else {
                [PSCustomObject]@{
                    User = $user
                    Status = "Not Locked"
                    Date = "--"
                    CheckTime = $cktime
                }
            }#else
        }#foreach
    }
    End {}
}
