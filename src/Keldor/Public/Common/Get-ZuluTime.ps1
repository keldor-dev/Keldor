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

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-ZuluTime
#>

  [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-ZuluTime')]
  param ()
  (Get-Date).ToUniversalTime()
}
