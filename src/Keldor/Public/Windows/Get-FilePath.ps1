function Get-FilePath {
<#
.SYNOPSIS
    Gets File Path.

.DESCRIPTION
    Gets File Path.

.EXAMPLE
    Get-FilePath
    Runs Get-FilePath.

.OUTPUTS
    System.Object

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 09/21/2017 13:05:42
    LASTEDIT: 09/21/2017 13:05:42
    KEYWORDS:

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-FilePath
#>





        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-FilePath')]
    Param ()
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = "C:\"
    $OpenFileDialog.filter = "All files (*.*)| *.*"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
    $OpenFileDialog.ShowHelp = $true
}
