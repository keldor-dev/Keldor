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

.NOTES
    AUTHOR: Skyler Hart
    CREATED: Sometime before 2017-08-07
    LASTEDIT: 08/18/2017 20:47:06
    KEYWORDS:

.LINK
    https://docs.keldor.dev/powershell/keldor/Set-SpeakerVolume
#>





    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Set-SpeakerVolume')]
    [Alias('Volume')]
    Param (
        [switch]$min,
        [switch]$max,
        [int32]$volume = "10",
        [switch]$mute
    )

    $volume = ($volume/2)
    $wshShell = new-object -com wscript.shell

    If ($min) {1..50 | ForEach-Object {$wshShell.SendKeys([char]174)}}
    ElseIf ($max) {1..50 | ForEach-Object {$wshShell.SendKeys([char]175)}}
    elseif ($mute) {$wshShell.SendKeys([char]173)}#turns sound on or off dependent on what it was before
    elseif ($volume) {1..50 | ForEach-Object {$wshShell.SendKeys([char]174)};1..$Volume | ForEach-Object {$wshShell.SendKeys([char]175)}}
}
