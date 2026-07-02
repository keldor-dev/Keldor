function Get-FolderPath {
<#
.SYNOPSIS
    Gets Folder Path.

.DESCRIPTION
    Gets Folder Path.

.EXAMPLE
    Get-FolderPath
    Runs Get-FolderPath.

.OUTPUTS
    System.Object

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 09/21/2017 13:05:51
    LASTEDIT: 09/21/2017 13:05:51
    KEYWORDS:

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-FolderPath
#>





        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-FolderPath')]
    Param ()
Write-Output "The folder selection window is open. It may be hidden behind windows."
    Add-Type -AssemblyName System.Windows.Forms
    $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    #$FolderBrowser.Description = "Select Folder"
    #$FolderBrowser.ShowNewFolderButton = $false
    #$FolderBrowser.RootFolder = 'MyComputer'
    #to see special folders:  [Enum]::GetNames([System.Environment+SpecialFolder])
    #special folders can be used in the RootFolder section
    #Set-WindowState MINIMIZE
    [void]$FolderBrowser.ShowDialog()
    #Set-WindowState RESTORE
    $FolderBrowser.SelectedPath
}
