function Open-HIPSLog {
<#
.SYNOPSIS
    Opens HIPS Log.

.DESCRIPTION
    Opens HIPS Log.

.EXAMPLE
    Open-HIPSLog
    Runs Open-HIPSLog.

.OUTPUTS
    None

.NOTES
    AUTHOR: Skyler Hart
    CREATED: Sometime before 8/7/2017
    LASTEDIT: 08/18/2017 21:11:22
    KEYWORDS:
    REQUIRES:
    #Requires -Version 3.0
    #Requires -Modules ActiveDirectory
    #Requires -PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
    #Requires -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-HIPSLog
#>





        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-HIPSLog')]
    Param ()
explorer "$env:ProgramData\McAfee\Host Intrusion Prevention"
}
