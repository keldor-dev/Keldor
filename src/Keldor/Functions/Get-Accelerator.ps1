function Get-Accelerator {
<#
.Notes
    AUTHOR: Skyler Hart
    CREATED: 12/21/2019 23:28:57
    LASTEDIT: 12/21/2019 23:28:57
    KEYWORDS:
.LINK
    https://docs.keldor.dev
#>
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-Accelerator')]
    [Alias('Get-TypeAccelerators','accelerators')]
    param()

    [psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators")::get | Sort-Object Key
}
