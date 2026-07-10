function Update-WSTools {
    <#
.SYNOPSIS
    This updates the Keldor module

.DESCRIPTION
    Updates the Keldor module in various locations

.EXAMPLE
    Update-WSTools
    Will update the Keldor module

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Update-WSTools
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Update-WSTools')]
    param ()
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSUseSingularNouns",
        "",
        Justification = "Keldor is the proper name for the module."
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    $config = $Global:KeldorConfig
    $UPath = $config.UpdatePath
    $UComp = $config.UpdateComp
    $APaths = $config.AdditionalUpdatePaths

    if ($null -ne $UComp -and $env:COMPUTERNAME -eq $UComp) {
        Robocopy.exe $env:ProgramFiles\WindowsPowerShell\Modules\Keldor $UPath /mir /mt:4 /r:3 /w:5 /njh /njs
        if ($null -ne $APaths -or $APaths -eq "") {
            foreach ($apath in $APaths) {
                Write-Output "Updating $apath"
                Robocopy.exe $env:ProgramFiles\WindowsPowerShell\Modules\Keldor $apath /mir /mt:4 /r:3 /w:5 /njh /njs
            }
        }
    } else {
        robocopy $UPath $env:ProgramFiles\WindowsPowerShell\Modules\Keldor /mir /mt:4 /njs /njh /r:3 /w:15
    }
}
