function Open-AdminTools {
<#
   .Notes
    AUTHOR: Skyler Hart
    LASTEDIT: 08/18/2017 20:48:27
    KEYWORDS:
    REQUIRES:
        #Requires -Version 3.0
        #Requires -Modules ActiveDirectory
        #Requires -PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
        #Requires -RunAsAdministrator
.LINK
    https://docs.keldor.dev/powershell/keldor/Open-AdminTools
#>
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-AdminTools')]
    [Alias('tools','admintools','admin')]
    param()
    control.exe admintools
}
