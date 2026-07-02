function Open-LocalGPeditor {
<#
.SYNOPSIS
    Opens Local G Peditor.

.DESCRIPTION
    Opens Local G Peditor.

.EXAMPLE
    Open-LocalGPeditor
    Runs Open-LocalGPeditor.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    CREATED: 08/19/2017 22:31:01
    LASTEDIT: 08/19/2017 22:31:01
    KEYWORDS:
    REQUIRES:
    #Requires -Version 3.0
    #Requires -Modules ActiveDirectory
    #Requires -PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
    #Requires -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-LocalGPeditor
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-LocalGPeditor')]
    [Alias('Open-LocalPolicyEditor','LocalPolicy')]
    param()
    gpedit.msc
}
