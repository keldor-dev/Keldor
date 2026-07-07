#Write help
#Add progress bar
function Find-UserProfile {
<#
.SYNOPSIS
    Finds User Profile.

.DESCRIPTION
    Finds User Profile.

.PARAMETER ComputerName
    Specifies the computer name to use.

.PARAMETER Username
    Specifies the Username value.

.EXAMPLE
    Find-UserProfile
    Runs Find-UserProfile.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Find-UserProfile
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Find-UserProfile')]
    Param (
        [Parameter(Mandatory=$false, Position=0)]
        [Alias('Host','Name','Computer','CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME",

        [Parameter(Mandatory=$false, Position=1)]
        [Alias('User','SamAccountname')]
        [string[]]$Username = "$env:USERNAME"
    )

    $i = 0

    foreach ($Comp in $ComputerName) {
            #Progress Bar
            $length = $ComputerName.length
            $i++
            if ($length -gt "1") {
                $number = $ComputerName.length
                $amount = ($i / $number)
                $perc1 = $amount.ToString("P")
                Write-Progress -activity "Getting profile status on computers" -status "Computer $i of $number. Percent complete:  $perc1" -PercentComplete (($i / $ComputerName.length)  * 100)
            }#if length
        $compath = "\\" + $Comp + "\c$"
        if (Test-Connection $Comp -quiet) {
        try {
            New-PSDrive -Name ProfCk -PSProvider FileSystem -root "$compath" -ErrorAction Stop | Out-Null

            foreach ($User in $Username) {
                try {
                    $modtime = $null
                    $usrpath = "ProfCk:\Users\$User"
                    if (Test-Path -Path $usrpath) {
                        $modtime = Get-Item $usrpath | ForEach-Object {$_.LastWriteTime}
                        [PSCustomObject]@{
                            Name = $Comp
                            Status = "Online"
                            User = $User
                            Profile = "Yes"
                            ModifiedTime = $modtime
                        } | Select-Object Name,Status,User,Profile,ModifiedTime
                    }#if user profile exists on computer
                    else {
                        [PSCustomObject]@{
                            Name = $Comp
                            Status = "Online"
                            User = $User
                            Profile = "No"
                            ModifiedTime = $null
                        } | Select-Object Name,Status,User,Profile,ModifiedTime
                    }#else no profile
                }#try
                Catch [System.UnauthorizedAccessException] {
                    [PSCustomObject]@{
                        Name = $Comp
                        Status = "Access Denied"
                        User = $user
                        Profile = "Possible"
                        ModifiedTime = $null
                    } | Select-Object Name,Status,User,Profile,ModifiedTime
                }#catch access denied
            }#foreach user
            Remove-PSDrive -Name ProfCk -ErrorAction SilentlyContinue -Force | Out-Null
        }#try new psdrive
        Catch {
            [PSCustomObject]@{
                Name = $Comp
                Status = "Comm Error"
                User = $null
                Profile = $null
                ModifiedTime = $null
            } | Select-Object Name,Status,User,Profile,ModifiedTime
        }#catch new psdrive
        }#if online
        else {
            [PSCustomObject]@{
                Name = $Comp
                Status = "Offline"
                User = $null
                Profile = $null
                ModifiedTime = $null
            } | Select-Object Name,Status,User,Profile,ModifiedTime
        }
    }#foreach computer
}
