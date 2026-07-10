function Get-KeldorSecretProviderInfoObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [object]$Definition,

        [Parameter()]
        [switch]$Detailed
    )

    switch ($Definition.Name) {
        'OnePassword' {
            $Command = Get-Command -Name 'op' -ErrorAction SilentlyContinue
            $Installed = $null -ne $Command
            $Authenticated = $false
            $Version = $null
            $CommandPath = $null
            $Status = 'NotInstalled'
            $StatusReason = "The 1Password CLI is not installed."

            if ($Installed) {
                $CommandPath = if ($Command.Source) { $Command.Source } else { $Command.Path }

                try {
                    $VersionOutput = & op --version 2>$null
                    if ($null -ne $VersionOutput) {
                        $Version = ([string]::Join(' ', @($VersionOutput))).Trim()
                    }
                } catch {
                    $Version = $null
                }

                try {
                    & op account get 2>$null | Out-Null
                    if ($Command.CommandType -ne 'Application' -or $LASTEXITCODE -eq 0) {
                        $Authenticated = $true
                    }
                } catch {
                    $Authenticated = $false
                }

                if ($Authenticated) {
                    $Status = 'Ready'
                    $StatusReason = 'The 1Password CLI is installed and authentication was confirmed.'
                } else {
                    $Status = 'NotAuthenticated'
                    $StatusReason = 'The 1Password CLI is installed, but authentication could not be confirmed.'
                }
            }

            $Available = $Installed -and $Authenticated

            $ProviderInfo = [ordered]@{
                PSTypeName          = 'Keldor.SecretProviderInfo'
                Name                = $Definition.Name
                DisplayName         = $Definition.DisplayName
                Installed           = $Installed
                Available           = $Available
                Authenticated       = $Authenticated
                CanRead             = $Definition.CanRead
                CanWrite            = $Definition.CanWrite
                CanRemove           = $Definition.CanRemove
                SupportsVault       = $Definition.SupportsVault
                SupportsField       = $Definition.SupportsField
                SupportsSecureInput = $Definition.SupportsSecureInput
                Priority            = $Definition.Priority
                Version             = $Version
                CommandPath         = $CommandPath
                ModuleName          = $null
                ModuleVersion       = $null
                Scope               = $null
                Prefix              = $null
                HasVault            = $null
                HasDefaultVault     = $null
                Status              = $Status
                StatusReason        = $StatusReason
            }
        }
        'SecretManagement' {
            $Module = Get-Module -ListAvailable -Name 'Microsoft.PowerShell.SecretManagement' -ErrorAction SilentlyContinue |
                Sort-Object -Property Version -Descending |
                Select-Object -First 1
            $Installed = $null -ne $Module
            $RequiredCommandNames = @('Get-Secret', 'Set-Secret', 'Remove-Secret', 'Get-SecretVault', 'Get-SecretInfo')
            $MissingCommands = @()
            foreach ($CommandName in $RequiredCommandNames) {
                if ($null -eq (Get-Command -Name $CommandName -ErrorAction SilentlyContinue)) {
                    $MissingCommands += $CommandName
                }
            }

            $Vaults = @()
            if ($Installed -and $MissingCommands.Count -eq 0) {
                try {
                    $Vaults = @(Get-SecretVault -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue -Verbose:$false -Debug:$false)
                } catch {
                    $Vaults = @()
                }
            }

            $HasVault = $Vaults.Count -gt 0
            $HasDefaultVault = $false
            foreach ($Vault in $Vaults) {
                if ($Vault.PSObject.Properties.Name -contains 'IsDefault' -and $Vault.IsDefault) {
                    $HasDefaultVault = $true
                    break
                }
            }

            if (-not $Installed) {
                $Status = 'NotInstalled'
                $StatusReason = 'Microsoft.PowerShell.SecretManagement is not installed.'
            } elseif ($MissingCommands.Count -gt 0) {
                $Status = 'PartiallyAvailable'
                $StatusReason = 'Microsoft.PowerShell.SecretManagement is installed, but one or more required commands are unavailable.'
            } elseif (-not $HasVault) {
                $Status = 'NotConfigured'
                $StatusReason = 'Microsoft.PowerShell.SecretManagement is installed, but no vaults are registered.'
            } else {
                $Status = 'Ready'
                $StatusReason = 'Microsoft.PowerShell.SecretManagement is installed and at least one vault is registered.'
            }

            $Available = $Installed -and $MissingCommands.Count -eq 0 -and $HasVault

            $ProviderInfo = [ordered]@{
                PSTypeName          = 'Keldor.SecretProviderInfo'
                Name                = $Definition.Name
                DisplayName         = $Definition.DisplayName
                Installed           = $Installed
                Available           = $Available
                Authenticated       = $null
                CanRead             = $Definition.CanRead
                CanWrite            = $Definition.CanWrite
                CanRemove           = $Definition.CanRemove
                SupportsVault       = $Definition.SupportsVault
                SupportsField       = $Definition.SupportsField
                SupportsSecureInput = $Definition.SupportsSecureInput
                Priority            = $Definition.Priority
                Version             = $null
                CommandPath         = $null
                ModuleName          = if ($Installed) { $Module.Name } else { $null }
                ModuleVersion       = if ($Installed) { [string]$Module.Version } else { $null }
                Scope               = $null
                Prefix              = $null
                HasVault            = $HasVault
                HasDefaultVault     = $HasDefaultVault
                Status              = $Status
                StatusReason        = $StatusReason
            }
        }
        'Environment' {
            $ProviderInfo = [ordered]@{
                PSTypeName          = 'Keldor.SecretProviderInfo'
                Name                = $Definition.Name
                DisplayName         = $Definition.DisplayName
                Installed           = $true
                Available           = $true
                Authenticated       = $null
                CanRead             = $Definition.CanRead
                CanWrite            = $Definition.CanWrite
                CanRemove           = $Definition.CanRemove
                SupportsVault       = $Definition.SupportsVault
                SupportsField       = $Definition.SupportsField
                SupportsSecureInput = $Definition.SupportsSecureInput
                Priority            = $Definition.Priority
                Version             = $null
                CommandPath         = $null
                ModuleName          = $null
                ModuleVersion       = $null
                Scope               = 'Process'
                Prefix              = 'KELDOR_SECRET_'
                HasVault            = $null
                HasDefaultVault     = $null
                Status              = 'Ready'
                StatusReason        = 'The Environment provider is available for process-scoped secrets.'
            }
        }
    }

    if (-not $Detailed) {
        $DefaultInfo = [ordered]@{
            PSTypeName    = $ProviderInfo.PSTypeName
            Name          = $ProviderInfo.Name
            DisplayName   = $ProviderInfo.DisplayName
            Installed     = $ProviderInfo.Installed
            Available     = $ProviderInfo.Available
            Authenticated = $ProviderInfo.Authenticated
            CanRead       = $ProviderInfo.CanRead
            CanWrite      = $ProviderInfo.CanWrite
            CanRemove     = $ProviderInfo.CanRemove
            Priority      = $ProviderInfo.Priority
            Status        = $ProviderInfo.Status
            StatusReason  = $ProviderInfo.StatusReason
        }

        return [pscustomobject]$DefaultInfo
    }

    [pscustomobject]$ProviderInfo
}
