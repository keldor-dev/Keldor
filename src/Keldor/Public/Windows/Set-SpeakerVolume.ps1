function Set-SpeakerVolume {
<#
.SYNOPSIS
    Sets Speaker Volume.

.DESCRIPTION
    Sets Speaker Volume.

.PARAMETER min
    Specifies whether to enable the min option.

.PARAMETER max
    Specifies whether to enable the max option.

.PARAMETER volume
    Specifies the volume value.

.PARAMETER mute
    Specifies whether to enable the mute option.

.EXAMPLE
    Set-SpeakerVolume
    Runs Set-SpeakerVolume.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-SpeakerVolume
#>

    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-SpeakerVolume')]
    [Alias('Volume')]
    Param (
        [switch]$min,
        [switch]$max,
        [int32]$volume = "10",
        [switch]$mute
    )

    $volume = ($volume/2)
    $wshShell = new-object -com wscript.shell

    If ($min) {
        if ($PSCmdlet.ShouldProcess('Speaker volume', "Set minimum")) {
            1..50 | ForEach-Object {$wshShell.SendKeys([char]174)}
        }
    }
    ElseIf ($max) {
        if ($PSCmdlet.ShouldProcess('Speaker volume', "Set maximum")) {
            1..50 | ForEach-Object {$wshShell.SendKeys([char]175)}
        }
    }
    elseif ($mute) {
        if ($PSCmdlet.ShouldProcess('Speaker volume', "Toggle mute")) {
            $wshShell.SendKeys([char]173)
        }
    }#turns sound on or off dependent on what it was before
    elseif ($volume) {
        if ($PSCmdlet.ShouldProcess('Speaker volume', "Set volume")) {
            1..50 | ForEach-Object {$wshShell.SendKeys([char]174)};1..$Volume | ForEach-Object {$wshShell.SendKeys([char]175)}
        }
    }
}
