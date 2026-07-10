function Get-ModuleCommandCount {
    <#
.SYNOPSIS
    Gets Module Command Count.

.DESCRIPTION
    Gets Module Command Count.

.PARAMETER Name
    Specifies the Name value.

.PARAMETER Functions
    Specifies whether to enable the Functions option.

.EXAMPLE
    Get-ModuleCommandCount -Name <value>
    Runs Get-ModuleCommandCount.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-ModuleCommandCount
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-ModuleCommandCount')]
    param(
        [Parameter(
            HelpMessage = "Enter the name of the module. It must be one that is imported.",
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Module')]
        [string]$Name,

        [switch]$Functions
    )

    if ($Functions) { (Get-Command -Module $Name -CommandType Function).Count }
    else { (Get-Command -Module $Name).Count }
}
