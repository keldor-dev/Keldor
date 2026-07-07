function Get-PowerShellVariable {
<#
.SYNOPSIS
    Will show env: and PowerShell variable active in session.

.DESCRIPTION
    Gets environment variables and the active PowerShell variables in the current session and shows their values.

.PARAMETER Name
    To filter for a specific variable.

.EXAMPLE
    Get-PowerShellVariable
    Example of how to use this cmdlet.

.EXAMPLE
    Get-PowerShellVariable -Name ErrorActionPreference
    Will show what the value is for $ErrorActionPreference.

.EXAMPLE
    Get-PowerShellVariable -Name ErrorActionPreference,OneDriveConsumer
    Will show what the value is for $ErrorActionPreference and $env:OneDriveConsumer.

.OUTPUTS
    System.Management.Automation.PSCustomObject

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-PowerShellVariable
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-PowerShellVariable')]
    param(
        [Parameter(Mandatory=$false)]
        [string[]]$Name
    )

    $variables = Get-ChildItem Env: | Add-Member -MemberType NoteProperty -Name "VariableType" -Value "`$env:" -PassThru
    $variables += Get-Variable | Add-Member -MemberType NoteProperty -Name "VariableType" -Value "PowerShell" -PassThru

    if (!([string]::IsNullOrWhiteSpace($Name))) {
        $filtered = foreach ($obj in $Name) {
            $variables | Where-Object {$_.Name -match $obj} | Select-Object VariableType,Name,Value
        }
    }
    else {
        $filtered = $variables | Select-Object VariableType,Name,Value
    }

    $filtered | Select-Object | Sort-Object Name
}
