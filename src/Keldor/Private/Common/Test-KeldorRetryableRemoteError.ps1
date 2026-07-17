function Test-KeldorRetryableRemoteError {
    [CmdletBinding()]
    param(
        [System.Management.Automation.ErrorRecord[]]$ErrorRecord
    )

    if (-not $ErrorRecord) {
        return $false
    }

    $text = (($ErrorRecord | ForEach-Object {
                $_.FullyQualifiedErrorId
                $_.Exception.GetType().FullName
                $_.Exception.Message
            }) -join ' ')

    if ($text -match '(?i)access is denied|authentication|authorization|credential|permission|publickey|host key') {
        return $false
    }

    return $text -match '(?i)PSRemotingTransportException|OpenError|ConnectionError|network path|connection.*(closed|refused|reset)|temporarily unavailable|timed out'
}
