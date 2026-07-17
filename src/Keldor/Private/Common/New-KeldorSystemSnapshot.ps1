function New-KeldorSystemSnapshot {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,

        [string]$Platform,

        [bool]$IsSuccessful = $true,

        [string]$ErrorCategory,

        [string]$ErrorCode,

        [string]$ErrorMessage
    )

    [pscustomobject][ordered]@{
        ComputerName      = $ComputerName
        Fqdn              = $null
        Platform          = $Platform
        OperatingSystem   = [pscustomobject][ordered]@{
            Name               = $null
            Caption            = $null
            Edition            = $null
            Version            = $null
            VersionString      = $null
            BuildNumber        = $null
            Architecture       = $null
            InstallationType   = $null
            IsServer           = $null
            IsDomainController = $null
            ProductType        = $null
            ProductId          = $null
            InstallDate        = $null
            LastBootTime       = $null
            Source             = $null
        }
        LinuxDistribution = [pscustomobject][ordered]@{
            Name            = $null
            Id              = $null
            IdLike          = $null
            PrettyName      = $null
            Version         = $null
            VersionId       = $null
            VersionCodename = $null
            BuildId         = $null
            Variant         = $null
            VariantId       = $null
            HomeUrl         = $null
            SupportUrl      = $null
            BugReportUrl    = $null
            SourcePath      = $null
        }
        Kernel            = [pscustomobject][ordered]@{
            KernelName             = $null
            KernelVersion          = $null
            KernelRelease          = $null
            Architecture           = $null
            HostName               = $null
            DomainName             = $null
            BootId                 = $null
            Is64BitOperatingSystem = $null
            Is64BitProcess         = [Environment]::Is64BitProcess
            Source                 = $null
        }
        Uptime            = [pscustomobject][ordered]@{
            LastBootTime = $null
            CurrentTime  = $null
            Uptime       = $null
            Source       = $null
        }
        Hardware          = [pscustomobject][ordered]@{
            Manufacturer           = $null
            Model                  = $null
            SerialNumber           = $null
            SystemUuid             = $null
            AssetTag               = $null
            ChassisType            = $null
            SystemType             = $null
            Architecture           = $null
            ProcessorManufacturer  = $null
            ProcessorModel         = $null
            ProcessorCount         = $null
            PhysicalCoreCount      = $null
            LogicalProcessorCount  = $null
            MemoryBytes            = $null
            FirmwareManufacturer   = $null
            FirmwareVersion        = $null
            FirmwareReleaseDate    = $null
            IsVirtualMachine       = $null
            VirtualizationPlatform = $null
            Source                 = $null
        }
        PowerShellVersion = $PSVersionTable.PSVersion
        PowerShellEdition = $PSVersionTable.PSEdition
        DotNetVersion     = [Environment]::Version
        AzureResourceId   = $null
        AzureArcStatus    = $null
        IsSuccessful      = $IsSuccessful
        ErrorCategory     = $ErrorCategory
        ErrorCode         = $ErrorCode
        ErrorMessage      = $ErrorMessage
        CollectedAt       = [datetimeoffset]::UtcNow
    }
}
