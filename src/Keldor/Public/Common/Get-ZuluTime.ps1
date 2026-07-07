function Get-ZuluTime {
  <#
.SYNOPSIS
    Gets Zulu Time.

.DESCRIPTION
    Gets Zulu Time.

.EXAMPLE
    Get-ZuluTime
    Runs Get-ZuluTime.

.OUTPUTS
    System.Object

.NOTES
    Author: Skyler Hart
    Created: 2021-06-10 22:28:39
    Last Edit: 2021-06-10 22:28:39

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-ZuluTime
#>







  [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-ZuluTime')]
  param ()
  (Get-Date).ToUniversalTime()
}
