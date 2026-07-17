function Resolve-KeldorVirtualization {
    [CmdletBinding()]
    param(
        [string]$Manufacturer,
        [string]$Model,
        [string]$FirmwareManufacturer
    )

    $evidence = @($Manufacturer, $Model, $FirmwareManufacturer) -join ' '
    $platform = $null

    switch -Regex ($evidence) {
        'Nutanix|AHV' { $platform = 'Nutanix AHV'; break }
        'Microsoft Corporation.*Azure|Virtual Machine.*Azure' { $platform = 'Azure'; break }
        'Microsoft Corporation.*Virtual Machine|Hyper-V' { $platform = 'Hyper-V'; break }
        'VMware' { $platform = 'VMware'; break }
        'VirtualBox|innotek' { $platform = 'VirtualBox'; break }
        'Google Compute Engine|Google' { $platform = 'Google Compute Engine'; break }
        'Amazon EC2|Xen.*HVM' { $platform = 'AWS'; break }
        'KVM' { $platform = 'KVM'; break }
        'QEMU' { $platform = 'QEMU'; break }
        'Xen' { $platform = 'Xen'; break }
        'Parallels' { $platform = 'Parallels'; break }
        'VirtualMac|Apple Virtual' { $platform = 'Apple Virtualization'; break }
    }

    [pscustomobject]@{
        IsVirtualMachine       = if ($platform) { $true } else { $null }
        VirtualizationPlatform = $platform
    }
}
