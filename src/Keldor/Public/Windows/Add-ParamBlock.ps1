function Add-ParamBlock {
<#
.SYNOPSIS
    Adds Param Block.

.DESCRIPTION
    Adds Param Block.

.EXAMPLE
    Add-ParamBlock
    Runs Add-ParamBlock.

.OUTPUTS
    System.Object

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 09/27/2017 15:14:53
    LASTEDIT: 12/20/2019 22:15:51
    KEYWORDS:

.LINK
    https://docs.keldor.dev/powershell/keldor/Add-ParamBlock
#>







        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Add-ParamBlock')]
    Param ()
$paramblockText = @"
    [CmdletBinding()]
    Param (
        [Parameter(HelpMessage = "Enter one or more computer names separated by commas.",
            Mandatory=`$false,
            Position=0,
            ValueFromPipeline = `$true,
            ValueFromPipelineByPropertyName = `$true
        )]
        [ValidateSet('Info','Error','Warning')]
        [ValidateNotNullOrEmpty()]
        [Alias('Host','Name','Computer','CN')]
        [string[]]`$ComputerName = "`$env:COMPUTERNAME",

        [Parameter()]
        [Switch]`$Switch
    )
"@
    $psise.CurrentFile.Editor.InsertText($paramblockText)
}
