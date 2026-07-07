function Add-DateTime {
  <#
.SYNOPSIS
    This function adds the date and time at current insertion point.

.DESCRIPTION
    This function adds the date and time at current insertion point.

.EXAMPLE
    Add-DateTime
    Adds date and time at current insertion point in a PowerShell ISE window.

.OUTPUTS
    System.Object

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 08/19/2017 19:51:23
    LASTEDIT: 10/26/2017 09:48:00
    KEYWORDS: Scripting Techniques, Windows PowerShell ISE

.LINK
    https://docs.keldor.dev/powershell/keldor/Add-DateTime
#>







  [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Add-DateTime')]
  param ()
  $timeText = @"
$(Get-Date)
"@
  $psise.CurrentFile.Editor.InsertText($timeText)
}
