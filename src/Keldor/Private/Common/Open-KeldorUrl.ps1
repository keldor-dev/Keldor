function Open-KeldorUrl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Url')]
        [string]$Uri,

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateSet('Default', 'Edge', 'Chrome', 'Firefox', 'Safari', 'InternetExplorer')]
        [string]$Browser = 'Default'
    )

    $SelectedBrowser = $Browser
    if ([string]::IsNullOrWhiteSpace($SelectedBrowser)) {
        $SelectedBrowser = 'Default'
    }

    if ($SelectedBrowser -eq 'Default') {
        Start-Process -FilePath $Uri
        return
    }

    $Platform = Get-KeldorPlatform

    if ($Platform -eq 'macOS') {
        $ApplicationNames = @{
            Edge             = 'Microsoft Edge'
            Chrome           = 'Google Chrome'
            Firefox          = 'Firefox'
            Safari           = 'Safari'
            InternetExplorer = 'Internet Explorer'
        }

        $ApplicationName = $ApplicationNames[$SelectedBrowser]
        if ($SelectedBrowser -eq 'InternetExplorer') {
            throw "Browser '$SelectedBrowser' is not available on macOS."
        }

        try {
            Start-Process -FilePath 'open' -ArgumentList @('-a', $ApplicationName, $Uri) -ErrorAction Stop
            return
        } catch {
            throw "Browser '$SelectedBrowser' was not found or could not be started on macOS."
        }
    }

    if ($Platform -eq 'Linux') {
        $LinuxBrowserCommands = @{
            Edge             = @('microsoft-edge', 'microsoft-edge-stable', 'msedge')
            Chrome           = @('google-chrome', 'google-chrome-stable', 'chromium', 'chromium-browser')
            Firefox          = @('firefox')
            Safari           = @()
            InternetExplorer = @()
        }

        foreach ($CommandName in $LinuxBrowserCommands[$SelectedBrowser]) {
            $Command = Get-Command -Name $CommandName -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($Command) {
                $FilePath = $Command.Source
                if ([string]::IsNullOrWhiteSpace($FilePath)) {
                    $FilePath = $CommandName
                }
                Start-Process -FilePath $FilePath -ArgumentList $Uri
                return
            }
        }

        if ($SelectedBrowser -eq 'Safari' -or $SelectedBrowser -eq 'InternetExplorer') {
            throw "Browser '$SelectedBrowser' is not available on Linux."
        }

        throw "Browser '$SelectedBrowser' was not found on Linux."
    }

    $WindowsBrowserCommands = @{
        Edge             = @('msedge.exe')
        Chrome           = @('chrome.exe')
        Firefox          = @('firefox.exe')
        Safari           = @('safari.exe')
        InternetExplorer = @('iexplore.exe')
    }

    foreach ($CommandName in $WindowsBrowserCommands[$SelectedBrowser]) {
        $Command = Get-Command -Name $CommandName -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($Command) {
            $FilePath = $Command.Source
            if ([string]::IsNullOrWhiteSpace($FilePath)) {
                $FilePath = $CommandName
            }
        } else {
            $FilePath = $CommandName
        }

        try {
            Start-Process -FilePath $FilePath -ArgumentList $Uri -ErrorAction Stop
            return
        } catch {
            $FilePath = $null
        }
    }

    if ($SelectedBrowser -eq 'Edge') {
        try {
            Start-Process -FilePath "microsoft-edge:$Uri" -ErrorAction Stop
            return
        } catch {
            throw "Browser '$SelectedBrowser' was not found on Windows."
        }
    }

    throw "Browser '$SelectedBrowser' was not found on Windows."
}
