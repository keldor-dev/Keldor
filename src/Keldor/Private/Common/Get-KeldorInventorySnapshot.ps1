function Get-KeldorInventorySnapshot {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Local', 'ComputerName', 'PSSession')]
        [string]$TargetKind,

        [string[]]$ComputerName,

        [System.Management.Automation.Runspaces.PSSession[]]$PSSession,

        [pscredential]$Credential
    )

    # Share session ownership and per-target failure handling across inventory commands.
    if ($TargetKind -eq 'Local') {
        $snapshots = @(Get-KeldorSystemSnapshot)
    } elseif ($TargetKind -eq 'PSSession') {
        $snapshots = foreach ($session in $PSSession) {
            try {
                Get-KeldorRemoteSystemSnapshot -PSSession $session
            } catch {
                New-KeldorSystemSnapshot `
                    -ComputerName $session.ComputerName `
                    -Platform $null `
                    -IsSuccessful $false `
                    -ErrorCategory ([string]$_.CategoryInfo.Category) `
                    -ErrorCode $_.FullyQualifiedErrorId `
                    -ErrorMessage $_.Exception.Message
            }
        }
    } else {
        $snapshots = foreach ($target in $ComputerName) {
            $session = $null
            try {
                $sessionParameters = @{
                    ComputerName = $target
                    ErrorAction  = 'Stop'
                }
                if ($Credential) {
                    $sessionParameters.Credential = $Credential
                }

                $session = New-PSSession @sessionParameters
                Get-KeldorRemoteSystemSnapshot -PSSession $session
            } catch {
                New-KeldorSystemSnapshot `
                    -ComputerName $target `
                    -Platform $null `
                    -IsSuccessful $false `
                    -ErrorCategory ([string]$_.CategoryInfo.Category) `
                    -ErrorCode $_.FullyQualifiedErrorId `
                    -ErrorMessage $_.Exception.Message
            } finally {
                if ($session) {
                    Remove-PSSession -Session $session -ErrorAction SilentlyContinue
                }
            }
        }
    }

    $snapshots
}
