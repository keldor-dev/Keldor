function Start-KeldorCommandJob {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$TargetDescriptor,

        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,

        [object[]]$ArgumentList,

        [hashtable]$ConnectionParameter = @{}
    )

    $parameters = @{
        ScriptBlock = $ScriptBlock
        AsJob       = $true
        ErrorAction = 'Stop'
    }
    if ($ArgumentList) {
        $parameters.ArgumentList = $ArgumentList
    }

    if ($TargetDescriptor.TargetType -eq 'Session') {
        $parameters.Session = $TargetDescriptor.TargetObject
    } elseif ($TargetDescriptor.Transport -eq 'WSMan') {
        $parameters.ComputerName = $TargetDescriptor.Target
    } else {
        $parameters.HostName = $TargetDescriptor.Target
    }

    foreach ($key in $ConnectionParameter.Keys) {
        $parameters[$key] = $ConnectionParameter[$key]
    }

    Invoke-Command @parameters
}
