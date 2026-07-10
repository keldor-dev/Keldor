function Test-KeldorSecretProviderByDefinition {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [object]$Definition,

        [Parameter()]
        [string]$Vault,

        [Parameter()]
        [switch]$Detailed
    )

    $ProviderStart = Get-Date
    $Checks = @()

    switch ($Definition.Name) {
        'OnePassword' {
            $Command = Get-Command -Name 'op' -ErrorAction SilentlyContinue
            $CheckStart = Get-Date
            $Checks += New-KeldorSecretProviderCheckResult -Name 'ExecutablePresent' -Success ($null -ne $Command) -Status $(if ($null -ne $Command) { 'Passed' } else { 'Failed' }) -Message $(if ($null -ne $Command) { 'The 1Password CLI was found.' } else { 'The 1Password CLI was not found.' }) -Duration ((Get-Date) - $CheckStart)

            if ($null -eq $Command) {
                $Status = 'NotInstalled'
                $Message = 'The 1Password CLI is not installed.'
                break
            }

            $CheckStart = Get-Date
            $VersionSucceeded = $false
            try {
                & op --version 2>$null | Out-Null
                if ($Command.CommandType -ne 'Application' -or $LASTEXITCODE -eq 0) {
                    $VersionSucceeded = $true
                }
            }
            catch {
                $VersionSucceeded = $false
            }
            $Checks += New-KeldorSecretProviderCheckResult -Name 'VersionAvailable' -Success $VersionSucceeded -Status $(if ($VersionSucceeded) { 'Passed' } else { 'Failed' }) -Message $(if ($VersionSucceeded) { 'The 1Password CLI version command succeeded.' } else { 'The 1Password CLI version command failed.' }) -Duration ((Get-Date) - $CheckStart)

            $CheckStart = Get-Date
            $Authenticated = $false
            try {
                & op whoami 2>$null | Out-Null
                if ($Command.CommandType -ne 'Application' -or $LASTEXITCODE -eq 0) {
                    $Authenticated = $true
                }
            }
            catch {
                $Authenticated = $false
            }
            $Checks += New-KeldorSecretProviderCheckResult -Name 'Authenticated' -Success $Authenticated -Status $(if ($Authenticated) { 'Passed' } else { 'Failed' }) -Message $(if ($Authenticated) { '1Password authentication was confirmed.' } else { '1Password authentication could not be confirmed.' }) -Duration ((Get-Date) - $CheckStart)

            if (-not [string]::IsNullOrWhiteSpace($Vault)) {
                $CheckStart = Get-Date
                $VaultAccessible = $false
                try {
                    & op vault get $Vault 2>$null | Out-Null
                    if ($Command.CommandType -ne 'Application' -or $LASTEXITCODE -eq 0) {
                        $VaultAccessible = $true
                    }
                }
                catch {
                    $VaultAccessible = $false
                }
                $Checks += New-KeldorSecretProviderCheckResult -Name 'VaultAccessible' -Success $VaultAccessible -Status $(if ($VaultAccessible) { 'Passed' } else { 'Failed' }) -Message $(if ($VaultAccessible) { "The requested 1Password vault is accessible." } else { "The requested 1Password vault could not be confirmed." }) -Duration ((Get-Date) - $CheckStart)
            }

            $Operational = $VersionSucceeded -and $Authenticated
            if (-not [string]::IsNullOrWhiteSpace($Vault)) {
                $Operational = $Operational -and $VaultAccessible
            }
            $Checks += New-KeldorSecretProviderCheckResult -Name 'ProviderOperational' -Success $Operational -Status $(if ($Operational) { 'Passed' } else { 'Failed' }) -Message $(if ($Operational) { 'The 1Password provider passed all required checks.' } else { 'The 1Password provider did not pass all required checks.' }) -Duration ([timespan]::Zero)

            $Status = if ($Operational) { 'Passed' } elseif (-not $Authenticated) { 'NotAuthenticated' } else { 'Failed' }
            $Message = if ($Operational) { 'Provider passed all required checks.' } else { 'Provider did not pass all required checks.' }
        }
        'SecretManagement' {
            $Module = Get-Module -ListAvailable -Name 'Microsoft.PowerShell.SecretManagement' -ErrorAction SilentlyContinue | Select-Object -First 1
            $CheckStart = Get-Date
            $ModuleInstalled = $null -ne $Module
            $Checks += New-KeldorSecretProviderCheckResult -Name 'ModuleInstalled' -Success $ModuleInstalled -Status $(if ($ModuleInstalled) { 'Passed' } else { 'Failed' }) -Message $(if ($ModuleInstalled) { 'Microsoft.PowerShell.SecretManagement is installed.' } else { 'Microsoft.PowerShell.SecretManagement is not installed.' }) -Duration ((Get-Date) - $CheckStart)

            $RequiredCommandNames = @('Get-SecretVault', 'Test-SecretVault')
            $MissingCommands = @()
            $CheckStart = Get-Date
            foreach ($CommandName in $RequiredCommandNames) {
                if ($null -eq (Get-Command -Name $CommandName -ErrorAction SilentlyContinue)) {
                    $MissingCommands += $CommandName
                }
            }
            $CommandsAvailable = $MissingCommands.Count -eq 0
            $Checks += New-KeldorSecretProviderCheckResult -Name 'CommandsAvailable' -Success $CommandsAvailable -Status $(if ($CommandsAvailable) { 'Passed' } else { 'Failed' }) -Message $(if ($CommandsAvailable) { 'Required SecretManagement commands are available.' } else { 'One or more required SecretManagement commands are unavailable.' }) -Duration ((Get-Date) - $CheckStart)

            $Vaults = @()
            if ($ModuleInstalled -and $CommandsAvailable) {
                try {
                    $Vaults = @(Get-SecretVault -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue -Verbose:$false -Debug:$false)
                }
                catch {
                    $Vaults = @()
                }
            }

            if (-not [string]::IsNullOrWhiteSpace($Vault)) {
                $ApplicableVaults = @($Vaults | Where-Object { $_.Name -eq $Vault })
            }
            else {
                $ApplicableVaults = @($Vaults)
            }

            $VaultRegistered = $ApplicableVaults.Count -gt 0
            $Checks += New-KeldorSecretProviderCheckResult -Name 'VaultRegistered' -Success $VaultRegistered -Status $(if ($VaultRegistered) { 'Passed' } else { 'Failed' }) -Message $(if ($VaultRegistered) { 'An applicable SecretManagement vault is registered.' } else { 'No applicable SecretManagement vault is registered.' }) -Duration ([timespan]::Zero)

            $VaultOperational = $false
            if ($VaultRegistered) {
                $VaultOperational = $true
                foreach ($RegisteredVault in $ApplicableVaults) {
                    $CheckStart = Get-Date
                    $VaultPassed = $false
                    try {
                        $VaultPassed = [bool](Test-SecretVault -Name $RegisteredVault.Name -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue -Verbose:$false -Debug:$false)
                    }
                    catch {
                        $VaultPassed = $false
                    }

                    if (-not $VaultPassed) {
                        $VaultOperational = $false
                    }

                    $Checks += New-KeldorSecretProviderCheckResult -Name 'VaultOperational' -Success $VaultPassed -Status $(if ($VaultPassed) { 'Passed' } else { 'Failed' }) -Message $(if ($VaultPassed) { 'A SecretManagement vault passed its provider test.' } else { 'A SecretManagement vault did not pass its provider test.' }) -Duration ((Get-Date) - $CheckStart)
                }
            }
            else {
                $Checks += New-KeldorSecretProviderCheckResult -Name 'VaultOperational' -Success $false -Status 'Skipped' -Message 'Vault operational testing was skipped because no applicable vault is registered.' -Duration ([timespan]::Zero)
            }

            $Operational = $ModuleInstalled -and $CommandsAvailable -and $VaultRegistered -and $VaultOperational
            $Checks += New-KeldorSecretProviderCheckResult -Name 'ProviderOperational' -Success $Operational -Status $(if ($Operational) { 'Passed' } else { 'Failed' }) -Message $(if ($Operational) { 'The SecretManagement provider passed all required checks.' } else { 'The SecretManagement provider did not pass all required checks.' }) -Duration ([timespan]::Zero)

            if (-not $ModuleInstalled) {
                $Status = 'NotInstalled'
            }
            elseif (-not $VaultRegistered) {
                $Status = 'NotConfigured'
            }
            elseif ($Operational) {
                $Status = 'Passed'
            }
            else {
                $Status = 'Failed'
            }
            $Message = if ($Operational) { 'Provider passed all required checks.' } else { 'Provider did not pass all required checks.' }
        }
        'Environment' {
            if (-not [string]::IsNullOrWhiteSpace($Vault)) {
                throw "Parameter -Vault is not supported by provider 'Environment'."
            }

            $CheckStart = Get-Date
            $ProcessScopeSupported = $true
            try {
                [Environment]::GetEnvironmentVariable('PATH', [EnvironmentVariableTarget]::Process) | Out-Null
            }
            catch {
                $ProcessScopeSupported = $false
            }
            $Checks += New-KeldorSecretProviderCheckResult -Name 'ProcessScopeSupported' -Success $ProcessScopeSupported -Status $(if ($ProcessScopeSupported) { 'Passed' } else { 'Failed' }) -Message $(if ($ProcessScopeSupported) { 'Process-scoped environment access is supported.' } else { 'Process-scoped environment access is not supported.' }) -Duration ((Get-Date) - $CheckStart)

            $PrefixValid = -not [string]::IsNullOrWhiteSpace('KELDOR_SECRET_')
            $Checks += New-KeldorSecretProviderCheckResult -Name 'PrefixValid' -Success $PrefixValid -Status $(if ($PrefixValid) { 'Passed' } else { 'Failed' }) -Message $(if ($PrefixValid) { 'The Keldor environment secret prefix is valid.' } else { 'The Keldor environment secret prefix is invalid.' }) -Duration ([timespan]::Zero)

            $Operational = $ProcessScopeSupported -and $PrefixValid
            $Checks += New-KeldorSecretProviderCheckResult -Name 'ProviderOperational' -Success $Operational -Status $(if ($Operational) { 'Passed' } else { 'Failed' }) -Message $(if ($Operational) { 'The Environment provider passed all required checks.' } else { 'The Environment provider did not pass all required checks.' }) -Duration ([timespan]::Zero)

            $Status = if ($Operational) { 'Passed' } else { 'Failed' }
            $Message = if ($Operational) { 'Provider passed all required checks.' } else { 'Provider did not pass all required checks.' }
        }
    }

    $Success = -not ($Checks | Where-Object { -not $_.Success -and $_.Status -ne 'Skipped' -and $_.Status -ne 'NotTested' })
    $Duration = (Get-Date) - $ProviderStart
    $Result = [ordered]@{
        PSTypeName = 'Keldor.SecretProviderTestResult'
        Name       = $Definition.Name
        Success    = $Success
        Status     = $Status
        TestedAt   = Get-Date
        Duration   = $Duration
        Vault      = if ([string]::IsNullOrWhiteSpace($Vault)) { $null } else { $Vault }
        Message    = $Message
    }

    if ($Detailed) {
        $Result['Checks'] = $Checks
    }

    [pscustomobject]$Result
}
