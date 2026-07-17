function Invoke-KeldorNativeCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,

        [string[]]$ArgumentList = @()
    )

    $command = Get-Command -Name $FilePath -CommandType Application -ErrorAction Stop
    $output = @(& $command.Source @ArgumentList 2>&1)
    $exitCode = $LASTEXITCODE

    [pscustomobject]@{
        IsSuccessful = $exitCode -eq 0
        Output       = @($output | ForEach-Object { [string]$_ })
        ExitCode     = $exitCode
    }
}
