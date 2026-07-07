<#
.SYNOPSIS
    Defines Keldor-specific object types and shared type information.

.DESCRIPTION
    This file serves as the central location for Keldor-specific object
    definitions and shared type metadata.

    Historically, it was designed to provide a lightweight object model
    that could be used across the Keldor module while maintaining
    compatibility with Windows PowerShell 2.0.

    The long-term architectural vision includes providing standardized
    inventory and CMDB-style objects that can be shared between commands,
    allowing functions to return consistent object types regardless of
    their underlying implementation.

    Although only portions of this design are currently utilized, this
    file remains the canonical location for Keldor object definitions and
    should be preserved as the extension point for future object modeling.
#>
class Keldor {
  #Properties
  [datetime]$LastUpdate
  [string]$Version
  [string]$ScriptRoot
  [object]$Config

  #Methods
  hidden Init () {
    $manifestPath = Join-Path -Path $PSScriptRoot -ChildPath 'Keldor.psd1'
    if (!(Test-Path -Path $manifestPath)) {
      $root = Split-Path -Parent $PSScriptRoot
      $versionPath = Join-Path -Path $root -ChildPath '2024.12.1'
      $manifestPath = Join-Path -Path $versionPath -ChildPath 'Keldor.psd1'
    }

    $this.ScriptRoot = Split-Path -Parent $manifestPath
    $this.Config = $Global:KeldorConfig
    $this.Version = (Test-ModuleManifest $manifestPath).Version
    $this.LastUpdate = (Get-Item $manifestPath).LastWriteTime
  }

  [void] AddUserConfigItem ($Name, $Value) {
    $this.Config = $this.Config | Add-Member -NotePropertyName $Name -NotePropertyValue $Value -PassThru
  }

  [void] SaveUserConfig () {
    $ModuleConfig = "$PSScriptRoot\2024.12.1\Config.ps1"

    $items = $Global:KeldorConfig | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name

    $filetextstart = @"
`$Global:KeldorUserConfig = [PSCustomObject]@{
"@

    $filetextend = @"

}
"@

    $filetext = foreach ($i in $items) {
    		$Type = ($Global:KeldorConfig.$i).GetType() | Select-Object -ExpandProperty Name
      $Value = $Global:KeldorConfig.$i

      if (($ModuleConfig.$i -ne $Global:KeldorConfig.$i) -and $Type -eq "String") {
        @"

	$i = "$Value"
"@
      } elseif ($Type -eq "Int32") {
        @"

	$i = $Value
"@
      } elseif ($Type -eq "Boolean") {
        @"

	$i = `$$Value
"@
      } elseif ($Type -match "Object") {
        $Value = $Value -join "','"
        @"

	$i = @('$Value')
"@
      }
    }#file text

    $content = $filetextstart + $filetext + $filetextend
    $UserPowerShell = "$env:USERPROFILE\.Keldor"

    if (!(Test-Path $UserPowerShell)) {
      New-Item -Path $UserPowerShell -ItemType Directory
      Get-Item $UserPowerShell -Force | ForEach-Object {$_.Attributes = $_.Attributes -bor "Hidden"}
    }

    if (!(Test-Path $UserPowerShell\KeldorConfig.ps1)) {
      Set-Content -Path $UserPowerShell\KeldorConfig.ps1 -Value $content
    } else {
      $overwrite = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Yes'
      $cancel = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'No'
      $options = [System.Management.Automation.Host.ChoiceDescription[]]($overwrite, $cancel)

      $title = 'User config exists'
      $message = 'User configuration file already exists. Overwrite it?'
      $result = $Global:Host.ui.PromptForChoice($title, $message, $options, 0)

      switch ($result) {
        0 {Set-Content -Path $UserPowerShell\KeldorConfig.ps1 -Value $content; Write-Host "Overwrote user config file"}
        1 {Write-Host "Cancelled"}
      }
    }
  }#save user config

  [string] Update () {
    Update-WSTools
    return "Update complete"
  }

  #Constructors
  Keldor () {
    $this.Init()
  }
}

$Global:Keldor = [Keldor]::new()
