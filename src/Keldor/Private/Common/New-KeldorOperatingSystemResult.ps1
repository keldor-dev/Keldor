function New-KeldorOperatingSystemResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Snapshot
    )

    $value = $Snapshot.OperatingSystem
    $result = [pscustomobject][ordered]@{
        ComputerName       = $Snapshot.ComputerName
        Platform           = $Snapshot.Platform
        Name               = $value.Name
        Caption            = $value.Caption
        Edition            = $value.Edition
        Version            = ConvertTo-KeldorVersion -Value $value.Version
        VersionString      = $value.VersionString
        BuildNumber        = $value.BuildNumber
        Architecture       = $value.Architecture
        InstallationType   = $value.InstallationType
        IsServer           = $value.IsServer
        IsDomainController = $value.IsDomainController
        ProductType        = $value.ProductType
        ProductId          = $value.ProductId
        InstallDate        = $value.InstallDate
        LastBootTime       = $value.LastBootTime
        Source             = $value.Source
        IsSuccessful       = $Snapshot.IsSuccessful
        ErrorCategory      = $Snapshot.ErrorCategory
        ErrorCode          = $Snapshot.ErrorCode
        ErrorMessage       = $Snapshot.ErrorMessage
        CollectedAt        = $Snapshot.CollectedAt
    }
    $result.PSObject.TypeNames.Insert(0, 'Keldor.OperatingSystem')
    $result
}
