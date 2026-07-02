function Get-IEVersion {
    <#
    .Notes
        AUTHOR: Skyler Hart
        CREATED: 09/21/2017 13:06:15
        LASTEDIT: 09/21/2017 13:06:15

    .LINK
        https://docs.keldor.dev
    #>
    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-IEVersion')]
    Param (
        [Parameter(
            Mandatory=$false,
            Position=0
        )]
        [Alias('Host','Name','Computer','CN')]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )

    $keyname = 'SOFTWARE\\Microsoft\\Internet Explorer'
    foreach ($comp in $ComputerName) {
        $reg = $null
        $key = $null
        $value = $null
        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $comp)
        $key = $reg.OpenSubkey($keyname)
        $value = $key.GetValue('Version')
        [PSCustomObject]@{
            ComputerName = $comp
            IEVersion = $value
        }# new object
    }# foreach computer
}
