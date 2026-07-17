function Get-KeldorWindowsManagementObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ClassName
    )

    if (Get-Command -Name Get-CimInstance -ErrorAction SilentlyContinue) {
        return Get-CimInstance -ClassName $ClassName -ErrorAction Stop
    }

    Get-WmiObject -Class $ClassName -ErrorAction Stop
}
