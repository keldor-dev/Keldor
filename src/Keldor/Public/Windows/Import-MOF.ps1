function Import-MOF {
<#
.SYNOPSIS
    Imports MOF.

.DESCRIPTION
    Imports MOF.

.PARAMETER Path
    Specifies the path to the mof file intended to import.

.EXAMPLE
    Import-MOF C:\Example\windows10.mof
    Example of how to use this cmdlet.

.EXAMPLE
    New-WMIFilter 'C:\setup\GPOs\WMIs\Google Chrome\Google Chrome.mof'
    Example of how to use this cmdlet.

.EXAMPLE
    Import-MOF -Path C:\Example\virtualservers.mof
    Another example of how to use this cmdlet but with a parameter or switch.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Import-MOF
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Import-MOF')]
    [Alias('Import-WMIFilter')]
    Param (
        [Parameter(
            HelpMessage = "Enter the path of the .mof file you want to import. Ex: C:\Example\examplewmi.mof",
            Mandatory=$true,
            Position=0
        )]
        [Alias('mof','Name','File')]
        [string]$Path
    )

    $auth = 'Author = ' + '"' + $env:username + '@' + $env:USERDNSDOMAIN + '"'
    $dom = 'Domain = ' + '"' + $env:USERDNSDOMAIN + '"'
    $content = Get-Content $Path
    $content2 = $content -replace 'Author = \"(.*)\"',"$auth" -replace "",""
    $content2 = $content2 -replace 'Domain = \"(.*)\"',"$dom"
    $content2 > $Path
    mofcomp -N:root\Policy $Path
}
