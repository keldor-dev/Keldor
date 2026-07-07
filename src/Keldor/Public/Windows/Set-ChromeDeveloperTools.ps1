function Set-ChromeDeveloperTools {
<#
.SYNOPSIS
    Will enable or disable Chrome Developer tools.

.DESCRIPTION
    Sets the registry entry HKLM:\SOFTWARE\Policies\Google\Chrome\DeveloperToolsDisabled to 1 (Disabled) or 0 (Enabled)

.PARAMETER Disable
    Will Disable Chrome Developer Tools.

.EXAMPLE
    Set-ChromeDeveloperTools
    Example of how to use this cmdlet to enable Chrome Developer Tools.

.EXAMPLE
    Set-ChromeDeveloperTools -Disable
    Example of how to use this cmdlet to disable Chrome Developer Tools.

.OUTPUTS
    System.Management.Automation.PSCustomObject

.NOTES
    Author: Skyler Hart
    Created: 2022-09-20 19:53:22
    Last Edit: 2022-09-20 19:53:22
    Other:
    Requires:
    -RunAsAdministrator

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-ChromeDeveloperTools
#>





    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSUseSingularNouns",
        "",
        Justification = "Developer Tools is the actual name of the setting so keeping it consistent."
    )]
    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-ChromeDeveloperTools')]
    [Alias('Set-DeveloperTools')]
    param(
        [Parameter()]
        [switch]$Disable
    )

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        if ($Disable) {
            try {
                Get-ItemPropertyValue -Path HKLM:\SOFTWARE\Policies\Google\Chrome -Name DeveloperToolsDisabled -ErrorAction Stop

                #modify entry
                if ($PSCmdlet.ShouldProcess('HKLM:\SOFTWARE\Policies\Google\Chrome\DeveloperToolsDisabled', "Set to 1")) {
                    Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Google\Chrome -Name DeveloperToolsDisabled -Value 1
                }
            }
            catch {
                #Create entry
                if ($PSCmdlet.ShouldProcess('HKLM:\SOFTWARE\Policies\Google\Chrome\DeveloperToolsDisabled', "Create with value 1")) {
                    New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Google\Chrome -Name DeveloperToolsDisabled -Value 1
                }
            }
        }
        else {
            try {
                Get-ItemPropertyValue -Path HKLM:\SOFTWARE\Policies\Google\Chrome -Name DeveloperToolsDisabled -ErrorAction Stop
                if ($PSCmdlet.ShouldProcess('HKLM:\SOFTWARE\Policies\Google\Chrome\DeveloperToolsDisabled', "Set to 0")) {
                    Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Google\Chrome -Name DeveloperToolsDisabled -Value 0
                }
            }
            catch {
                Write-Output "Chrome Developer Tools already enabled."
            }
        }
    }
    else {
        Write-Warning "Function must be ran as administrator."
    }
}
