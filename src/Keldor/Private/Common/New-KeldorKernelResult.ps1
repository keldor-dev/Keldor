function New-KeldorKernelResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Snapshot
    )

    $value = $Snapshot.Kernel
    $result = [pscustomobject][ordered]@{
        ComputerName           = $Snapshot.ComputerName
        Platform               = $Snapshot.Platform
        KernelName             = $value.KernelName
        KernelVersion          = $value.KernelVersion
        KernelRelease          = $value.KernelRelease
        Architecture           = $value.Architecture
        HostName               = $value.HostName
        DomainName             = $value.DomainName
        BootId                 = $value.BootId
        Is64BitOperatingSystem = $value.Is64BitOperatingSystem
        Is64BitProcess         = $value.Is64BitProcess
        Source                 = $value.Source
        IsSuccessful           = $Snapshot.IsSuccessful
        ErrorCategory          = $Snapshot.ErrorCategory
        ErrorCode              = $Snapshot.ErrorCode
        ErrorMessage           = $Snapshot.ErrorMessage
        CollectedAt            = $Snapshot.CollectedAt
    }
    $result.PSObject.TypeNames.Insert(0, 'Keldor.Kernel')
    $result
}
