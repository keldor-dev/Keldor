function Get-KeldorRemoteSystemSnapshot {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Runspaces.PSSession]$PSSession
    )

    Invoke-Command -Session $PSSession -ErrorAction Stop -ScriptBlock {
        $module = Import-Module Keldor -PassThru -ErrorAction Stop
        & $module { Get-KeldorSystemSnapshot }
    }
}
