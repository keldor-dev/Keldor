function New-KeldorRemoteCommandScriptBlock {
    [CmdletBinding()]
    param()

    {
        param(
            [string]$KeldorCommand,
            [hashtable]$Parameter
        )

        try {
            Import-Module -Name Keldor -ErrorAction Stop
        } catch {
            $message = 'A compatible Keldor module must already be installed and importable on the target.'
            $exception = New-Object System.InvalidOperationException $message, $_.Exception
            $record = New-Object System.Management.Automation.ErrorRecord (
                $exception,
                'Keldor.RemoteModuleUnavailable',
                [System.Management.Automation.ErrorCategory]::ResourceUnavailable,
                $KeldorCommand
            )
            throw $record
        }

        try {
            $command = Get-Command -Name $KeldorCommand -Module Keldor -CommandType Function, Cmdlet -ErrorAction Stop
        } catch {
            $message = "Keldor command '$KeldorCommand' is not available on the target."
            $exception = New-Object System.Management.Automation.CommandNotFoundException $message, $_.Exception
            $record = New-Object System.Management.Automation.ErrorRecord (
                $exception,
                'Keldor.RemoteCommandUnavailable',
                [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                $KeldorCommand
            )
            throw $record
        }

        if ($command.ModuleName -ne 'Keldor') {
            $message = "Resolved command '$KeldorCommand' does not belong to the Keldor module."
            $exception = New-Object System.InvalidOperationException $message
            $record = New-Object System.Management.Automation.ErrorRecord (
                $exception,
                'Keldor.RemoteCommandUnavailable',
                [System.Management.Automation.ErrorCategory]::InvalidResult,
                $KeldorCommand
            )
            throw $record
        }

        if ($null -eq $Parameter) {
            $Parameter = @{}
        }
        & $command @Parameter
    }
}
