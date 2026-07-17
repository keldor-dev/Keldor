function Get-KeldorWindowsManagementObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ClassName
    )

    Get-CimInstance -ClassName $ClassName -ErrorAction Stop
}
