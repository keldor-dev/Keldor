function Set-MTU {
<#
.SYNOPSIS
    Sets MTU.

.DESCRIPTION
    Sets MTU.

.PARAMETER Size
    Specifies the Size value.

.EXAMPLE
    Set-MTU
    Runs Set-MTU.

.OUTPUTS
    None

.NOTES
    Author: Skyler Hart
    Created: 2020-05-12 20:56:13
    Last Edit: 2020-05-12 20:56:13
    Keywords:
    Requires:
    -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-MTU
#>





	[CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-MTU')]
    Param (
        [Parameter(
            Mandatory=$false,
            Position=0
        )]
        [int32]$Size = 1500
    )
    Set-NetIPInterface -AddressFamily IPv4 -NlMtuBytes $Size
}
