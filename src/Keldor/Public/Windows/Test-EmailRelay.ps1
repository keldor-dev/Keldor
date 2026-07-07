function Test-EmailRelay {
<#
.SYNOPSIS
    Tests Email Relay.

.DESCRIPTION
    Tests Email Relay.

.PARAMETER Recipient
    Specifies the Recipient value.

.EXAMPLE
    Test-EmailRelay -Recipient <value>
    Runs Test-EmailRelay.

.OUTPUTS
    System.Object

.NOTES
    REMARKS: On secure networks, port 25 has to be open

.LINK
    https://docs.keldor.dev/powershell/keldor/Test-EmailRelay
#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars",
        "",
        Justification = "Have tried other methods and they do not work consistently."
    )]
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Test-EmailRelay')]
    [Alias('Test-SMTPRelay','Test-MailRelay')]
    Param (
        [Parameter(
            Mandatory=$true,
            Position=0,
            HelpMessage="Enter e-mail address of recipient")]
        [string]$Recipient
    )

    $config = $Global:KeldorConfig
    $from = $config.Sender
    $smtpserver = $config.SMTPServer
    $port = $config.SMTPPort

    $date = Get-Date
    $subject = "Test from $env:COMPUTERNAME $date"

    send-mailmessage -To $Recipient -From $from -Subject $subject -Body "Testing relay of SMTP messages.`nFrom: $from `nTo: $Recipient `n`nPlease delete this message." -smtpserver $smtpserver -Port $port
}
