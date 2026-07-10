function Copy-UserProfile {
    <#
.SYNOPSIS
    Copies User Profile.

.DESCRIPTION
    Copies User Profile.

.PARAMETER UserName
    Specifies the UserName value.

.PARAMETER ComputerName
    Specifies the computer name to use.

.PARAMETER DestinationPath
    Specifies the destination path value.

.EXAMPLE
    Copy-UserProfile -UserName <value>
    Runs Copy-UserProfile.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Copy-UserProfile
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Copy-UserProfile')]
    param (
        [Parameter(
            HelpMessage = 'Enter user name. Ex: "1234567890A" without quotes',
            Mandatory = $true,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('User', 'Username', 'SamAccountName')]
        [string]$UserName,

        [Parameter(HelpMessage = "Enter one or more computer names separated by commas.",
            Mandatory = $false,
            Position = 1,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME",

        [Parameter(HelpMessage = "Enter destination folder path as UNC unless a local path. Ex: E:\ESI\10-001 or \\COMP\e$\ESI\10-001",
            Mandatory = $false
        )]
        [Alias('Destination', 'Dest', 'DestinationFolder', 'DestFolder')]
        [string]$DestinationPath = $null
    )
    begin {
        if ($DestinationPath -eq $null) {
            Write-Output "The destination folder selection window is open. It may be hidden behind windows."
            Add-Type -AssemblyName System.Windows.Forms
            $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
            $FolderBrowser.Description = "Select destination folder for user profile."
            $FolderBrowser.RootFolder = 'MyComputer'
            Set-WindowState MINIMIZE
            [void]$FolderBrowser.ShowDialog()
            Set-WindowState RESTORE
            $DestinationPath = $FolderBrowser.SelectedPath
        }
        $df = $DestinationPath + "\" + $UserName
    }
    process {
        foreach ($comp in $ComputerName) {
            robocopy \\$comp\c$\Users\$UserName $df /mir /mt:3 /xj /r:3 /w:5 /njh /njs
        }
    }
    end {}
}
