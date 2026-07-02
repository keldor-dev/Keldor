function Add-Switch {
<#
.SYNOPSIS
    Adds Switch.

.DESCRIPTION
    Adds Switch.

.EXAMPLE
    Add-Switch
    Runs Add-Switch.

.OUTPUTS
    System.Object

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 07/31/2019 22:17:04
    LASTEDIT: 07/31/2019 22:17:04
    KEYWORDS:

.LINK
    https://docs.keldor.dev/powershell/keldor/Add-Switch
#>







        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Add-Switch')]
    Param ()
$objectText = @"
switch (`$variable) {
    value {`$variable2 = "something"}

    {'value1','value2' -contains `$_} {`$variable2 = "something"}

    {`$anothervariable -match `$variable} {`$variable2 = "something"}
}
"@
    $psise.CurrentFile.Editor.InsertText($objectText)
}
