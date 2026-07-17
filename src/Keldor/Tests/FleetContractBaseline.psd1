@{
    # Existing public-command formatting debt. Additions require compatibility review and an audit update.
    AllowedPublicFormattingCommands = @{
        'Get-LockedOutLocation'   = @('Format-Table')
        'Get-UserLogonLogoffTime' = @('Format-List')
    }
}
