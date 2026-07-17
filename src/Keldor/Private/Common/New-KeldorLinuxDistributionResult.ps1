function New-KeldorLinuxDistributionResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Snapshot
    )

    $value = $Snapshot.LinuxDistribution
    $result = [pscustomobject][ordered]@{
        ComputerName    = $Snapshot.ComputerName
        Platform        = $Snapshot.Platform
        Name            = $value.Name
        Id              = $value.Id
        IdLike          = $value.IdLike
        PrettyName      = $value.PrettyName
        Version         = $value.Version
        VersionId       = $value.VersionId
        VersionCodename = $value.VersionCodename
        BuildId         = $value.BuildId
        Variant         = $value.Variant
        VariantId       = $value.VariantId
        HomeUrl         = $value.HomeUrl
        SupportUrl      = $value.SupportUrl
        BugReportUrl    = $value.BugReportUrl
        SourcePath      = $value.SourcePath
        IsSuccessful    = $Snapshot.IsSuccessful
        ErrorCategory   = $Snapshot.ErrorCategory
        ErrorCode       = $Snapshot.ErrorCode
        ErrorMessage    = $Snapshot.ErrorMessage
        CollectedAt     = $Snapshot.CollectedAt
    }
    $result.PSObject.TypeNames.Insert(0, 'Keldor.LinuxDistribution')
    $result
}
