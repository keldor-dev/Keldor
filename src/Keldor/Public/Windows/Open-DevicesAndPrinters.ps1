function Open-DevicesAndPrinters {
<#
.SYNOPSIS
    Opens Devices And Printers.

.DESCRIPTION
    Opens Devices And Printers.

.EXAMPLE
    Open-DevicesAndPrinters
    Runs Open-DevicesAndPrinters.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Open-DevicesAndPrinters
#>

        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Open-DevicesAndPrinters')]
    Param ()
control.exe printers
}
