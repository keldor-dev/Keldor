function Get-USBDevice {
<#
.SYNOPSIS
    Gets USB Device.

.DESCRIPTION
    Gets USB Device.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Get-USBDevice
    Runs Get-USBDevice.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-USBDevice
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-USBDevice')]
    [Alias('usb')]
    Param (
        [Parameter(Mandatory=$false, Position=0)]
        [Alias('Host','Name','Computer','CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    foreach ($comp in $ComputerName) {
    Get-WmiObject Win32_USBControllerDevice -ComputerName $comp | ForEach-Object {[wmi]($_.Dependent)} | `
        Where-Object {$_.Name -notmatch "Composite Device" -and $_.Name -notmatch "Input Device" -and $_.Name -notmatch "Root Hub" `
        -and $_.Name -notmatch "Keyboard Device" -and $_.Name -notlike "HID-*"} | `
        Select-Object SystemName,Caption,DeviceID,Manufacturer,Name,Description | Sort-Object Caption
    }
}
