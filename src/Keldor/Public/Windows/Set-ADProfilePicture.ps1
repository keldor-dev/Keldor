function Set-ADProfilePicture {
<#
.SYNOPSIS
    Sets AD Profile Picture.

.DESCRIPTION
    Sets AD Profile Picture.

.PARAMETER UserName
    Specifies the UserName value.

.EXAMPLE
    Set-ADProfilePicture -UserName <value>
    Runs Set-ADProfilePicture.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-ADProfilePicture
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-ADProfilePicture')]
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Username','User','SamAccountName')]
        [string]$UserName
    )

    if (Test-KeldorActiveDirectoryModule -Import -AsBoolean -Quiet) {
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.initialDirectory = "C:\"
        $OpenFileDialog.filter = "JPG (*.jpg)| *.jpg"
        $OpenFileDialog.ShowDialog() | Out-Null
        $OpenFileDialog.filename
        $OpenFileDialog.ShowHelp = $true
        $ppath = $OpenFileDialog.FileName

        $item = Get-Item $ppath
        if ($item.Length -gt 102400) {Throw "Unable to set $UserName's picture. Picture must be less than 100 KB. Also recommend max size of 96 x 96 pixels."}
        else {
            $photo1 = [byte[]](Get-Content $ppath -Encoding byte)
            if ($PSCmdlet.ShouldProcess($UserName, "Set AD profile picture")) {
                Set-ADUser $UserName -Replace @{thumbnailPhoto=$photo1}
            }
        }
    }
    else {
        Write-Warning "Active Directory module is not installed and is required to run this command."
    }
}
