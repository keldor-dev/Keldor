function Convert-ImageToBase64 {
<#
.SYNOPSIS
    Converts Image To Base64.

.DESCRIPTION
    Converts Image To Base64.

.PARAMETER ImagePath
    Specifies the path to use.

.EXAMPLE
    Convert-ImageToBase64 -ImagePath <value>
    Runs Convert-ImageToBase64.

.OUTPUTS
    System.Object

.NOTES
    Author: Skyler Hart
    Created: 2020-11-03 22:22:19
    Last Edit: 2020-11-03 22:22:19
    Keywords:

.LINK
    https://docs.keldor.dev/powershell/keldor/Convert-ImageToBase64
#>







    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Convert-ImageToBase64')]
    [Alias('Convert-ICOtoBase64')]
    param(
        [Parameter(
            HelpMessage = "Enter the path of the image you want to convert. Ex: D:\temp\image.jpg",
            Mandatory=$true
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ImagePath
    )

    $b64 = [convert]::ToBase64String((get-content $ImagePath -encoding byte))
    $b64
}
