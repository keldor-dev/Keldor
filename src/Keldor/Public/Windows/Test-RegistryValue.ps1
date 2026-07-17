function Test-RegistryValue {
    <#
.SYNOPSIS
    Tests Registry Value.

.DESCRIPTION
    Tests Registry Value.

.PARAMETER Path
    Specifies the path to use.

.PARAMETER Value
    Specifies the Value value.

.EXAMPLE
    Test-RegistryValue -Path 'HKLM:\SOFTWARE\Keldor' -Value 'Enabled'

    Tests whether the Enabled value exists under the Keldor registry key.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Test-RegistryValue
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Test-RegistryValue')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]$Path,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]$Value
    )

    try {
        Get-ItemPropertyValue -Path $Path -Name $Value -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}
