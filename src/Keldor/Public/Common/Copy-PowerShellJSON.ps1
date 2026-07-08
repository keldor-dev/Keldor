function Copy-PowerShellJSON {
  <#
.SYNOPSIS
    Enables PowerShell Snippets in Visual Studio Code.

.DESCRIPTION
    Copies the powershell.json file from the Keldor module resources folder to the current user's Visual Studio Code snippets directory.

.EXAMPLE
    Copy-PowerShellJSON
    Copies the powershell.json file from the Keldor module resources folder to the current user's Visual Studio Code snippets directory.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Copy-PowerShellJSON
#>

  [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Copy-PowerShellJSON')]
  [Alias('Update-PowerShellJSON', 'Set-PowerShellJSON')]
  param()

  $Platform = Get-KeldorPlatform

  switch ($Platform) {
    'Windows' {
      $snippetPath = Join-Path -Path $env:APPDATA -ChildPath 'Code/User/snippets'
    }
    'macOS' {
      $snippetPath = Join-Path -Path $HOME -ChildPath 'Library/Application Support/Code/User/snippets'
    }
    'Linux' {
      $snippetPath = Join-Path -Path $HOME -ChildPath '.config/Code/User/snippets'
    }
    default {
      throw "Unsupported platform '$Platform'."
    }
  }

  if (!(Test-Path -Path $snippetPath)) {
    New-Item -Path $snippetPath -ItemType Directory -Force | Out-Null
  }

  $ModuleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
  $SourcePath = Join-Path -Path $ModuleRoot -ChildPath 'Resources/powershell.json'

  if (!(Test-Path -Path $SourcePath)) {
    throw "Source file not found: $SourcePath"
  }

  $DestinationPath = Join-Path -Path $snippetPath -ChildPath 'powershell.json'
  Copy-Item -Path $SourcePath -Destination $DestinationPath -Force
}
