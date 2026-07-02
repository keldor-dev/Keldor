function Open-DevicesAndPrinters {
<#
   .Notes
    AUTHOR: Skyler Hart
    LASTEDIT: 08/18/2017 20:48:52
    KEYWORDS:
    REQUIRES:
        #Requires -Version 3.0
        #Requires -Modules ActiveDirectory
        #Requires -PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
        #Requires -RunAsAdministrator
.LINK
    https://docs.keldor.dev/powershell/keldor/Open-DevicesAndPrinters
#>
        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-DevicesAndPrinters')]
    Param ()
control.exe printers
}
