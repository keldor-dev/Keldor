function Join-File {
    <#
.SYNOPSIS
    Joins File.

.DESCRIPTION
    Joins File.

.PARAMETER Path
    Specifies the path to use.

.PARAMETER DestinationFolder
    Specifies the path to use.

.EXAMPLE
    Join-File -Path <value>
    Runs Join-File.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Join-File
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Join-File')]
    [Alias('Merge-File')]
    param (
        [Parameter(HelpMessage = "Enter the path of the folder with the part files you want to join.",
            Mandatory = $true,
            Position = 0
        )]
        [Alias('Source', 'InputLocation', 'SourceFolder')]
        [string]$Path,

        [Parameter(HelpMessage = "Enter the path where you want the joined file placed.",
            Mandatory = $false,
            Position = 1
        )]
        [Alias('OutputLocation', 'Output', 'DestinationPath', 'Destination')]
        [string]$DestinationFolder
    )

    $og = (Get-Location).Path
    $objs = Get-ChildItem $Path | Where-Object { $_.Name -like "*_Part*" }

    $myobjs = foreach ($obj in $objs) {
        $ext = $obj.Extension
        $name = $obj.Name
        $num = $name -replace "[\s\S]*.*(_Part)", "" -replace $ext, ""
        $fn = $obj.FullName
        $dp = $obj.Directory.FullName

        [PSCustomObject]@{
            FullName  = $fn
            Name      = $name
            Extension = $ext
            Num       = [int]$num
            Directory = $dp
        }#new object
    }

    $sobj = $myobjs | Sort-Object Num | Select-Object FullName, Name, Extension, Directory

    $fo = $sobj[0]
    $fon = $fo.Name
    $fon = $fon -replace "_Part01", ""
    $fd = $fo.Directory
    if ($DestinationFolder -eq "") {
        $fop = $fd + "\" + $fon
        Set-Location $fd
    } else {
        $fop = $DestinationFolder + "\" + $fon
        if (!(Test-Path $DestinationFolder)) {
            New-Item -Path $DestinationFolder -ItemType Directory
        }
        Set-Location $DestinationFolder
    }

    $WriteObj = New-Object System.IO.BinaryWriter([System.IO.File]::Create($fop))

    if ($host.Version.Major -ge 3) {
        $sobj.FullName | ForEach-Object {
            Write-Output "Appending $_ to $fop"
            $ReadObj = New-Object System.IO.BinaryReader([System.IO.File]::Open($_, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read))

            $WriteObj.BaseStream.Position = $WriteObj.BaseStream.Length
            $ReadObj.BaseStream.CopyTo($WriteObj.BaseStream)
            $WriteObj.BaseStream.Flush()

            $ReadObj.Close()
        }
    } else {
        [Byte[]]$Buffer = New-Object Byte[] 100MB

        $sobj.FullName | ForEach-Object {
            Write-Output "Appending $_ to $fop"
            $ReadObj = New-Object System.IO.BinaryReader([System.IO.File]::Open($_, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read))

            while ($ReadObj.BaseStream.Position -lt $ReadObj.BaseStream.Length) {
                $ReadBytes = $ReadObj.Read($Buffer, 0, $Buffer.Length)
                $WriteObj.Write($Buffer, 0, $ReadBytes)
            }

            $ReadObj.Close()
        }
    }

    $WriteObj.Close()
    Set-Location $og
}
