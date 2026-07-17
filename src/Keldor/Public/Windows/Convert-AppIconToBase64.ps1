function Convert-AppIconToBase64 {
    <#
.SYNOPSIS
    Converts an application's associated icon to Base64.

.DESCRIPTION
    Extracts the icon associated with a Windows application file and returns its bytes as a Base64 string.

.PARAMETER Path
    Specifies a path to one or more locations.

.EXAMPLE
    Convert-AppIconToBase64 -Path 'C:\Program Files\Example\Example.exe'

    Converts the application's associated icon to Base64.

.OUTPUTS
    System.String

.LINK
    https://docs.keldor.dev/powershell/keldor/Convert-AppIconToBase64
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Convert-AppIconToBase64')]
    param(
        [Parameter(
            HelpMessage = "Enter the path of the file to extract the icon from. Ex: C:\Temp\app.exe",
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.IO
    $Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($Path)
    $stream = New-Object System.IO.MemoryStream
    $Icon.Save($stream)
    $Bytes = $stream.ToArray()
    $stream.Flush()
    $stream.Dispose()
    $b64 = [convert]::ToBase64String($Bytes)
    $b64
}
