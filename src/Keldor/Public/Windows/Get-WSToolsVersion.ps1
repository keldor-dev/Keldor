function Get-WSToolsVersion {
    <#
.SYNOPSIS
    Gets WS Tools Version.

.DESCRIPTION
    Gets WS Tools Version.

.PARAMETER Remote
    Specifies whether to enable the Remote option.

.PARAMETER ComputerName
    Specifies the computer name to use.

.EXAMPLE
    Get-WSToolsVersion
    Runs Get-WSToolsVersion.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-WSToolsVersion
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-WSToolsVersion')]
    [Alias('WSToolsVersion')]
    param (
        [Parameter(Mandatory = $false)]
        [Switch]$Remote,

        [Parameter(Mandatory = $false)]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName
    )

    if ($Remote) {
        foreach ($comp in $ComputerName) {
            $path = "\\$comp\c$\Program Files\WindowsPowerShell\Modules\Keldor\Keldor.psd1"
            try {
                $info = Test-ModuleManifest $path
                $ver = $info.Version
            } catch {
                $ver = "NA"
            }

            try {
                $info2 = Get-Item $path
                $i2 = $info2.LastWriteTime
            } catch {
                $i2 = "NA"
            }

            $version = [PSCustomObject]@{
                ComputerName   = $comp
                WSToolsVersion = $ver
                Date           = $i2
                Path           = $path
            }#new object
            $version | Select-Object ComputerName, WSToolsVersion, Date, Path
        }
    } else {
        $ModuleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
        $path = Join-Path -Path $ModuleRoot -ChildPath 'Keldor.psd1'
        try {
            $info = Test-ModuleManifest $path
            $ver = $info.Version
        } catch {
            $ver = "NA"
        }

        try {
            $info2 = Get-Item $path
            $i2 = $info2.LastWriteTime
        } catch {
            $i2 = "NA"
        }
        $cn = $env:COMPUTERNAME

        $version = [PSCustomObject]@{
            ComputerName   = $cn
            WSToolsVersion = $ver
            Date           = $i2
            Path           = $path
        }#new object
        $version | Select-Object ComputerName, WSToolsVersion, Date, Path
    }
}
