function ConvertTo-KeldorInventoryResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('SystemInfo', 'OperatingSystem', 'LinuxDistribution', 'Kernel', 'Uptime', 'HardwareInfo')]
        [string]$Type,

        [Parameter(Mandatory = $true)]
        [object]$Snapshot
    )

    switch ($Type) {
        'SystemInfo' { New-KeldorSystemInfoResult -Snapshot $Snapshot }
        'OperatingSystem' { New-KeldorOperatingSystemResult -Snapshot $Snapshot }
        'LinuxDistribution' { New-KeldorLinuxDistributionResult -Snapshot $Snapshot }
        'Kernel' { New-KeldorKernelResult -Snapshot $Snapshot }
        'Uptime' { New-KeldorUptimeResult -Snapshot $Snapshot }
        'HardwareInfo' { New-KeldorHardwareInfoResult -Snapshot $Snapshot }
    }
}
