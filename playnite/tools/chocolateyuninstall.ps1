$ErrorActionPreference = 'Stop';

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  softwareName  = 'Playnite'
  fileType      = 'exe'
  validExitCodes= @(0)
  silentArgs    = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART'
  # softwareExe added 2018-01-13 due to the uninstaller not killing the process properly.
  softwareExe   = 'PlayniteUI'
}

$uninstalled = $false
[array]$key = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']

if ($key.Count -eq 1) {
  $key | % {
    $packageArgs['file'] = "$($_.UninstallString)"
    # Stop-Process called before the uninstall to make sure uninstall goes through successfully.
    Write-Host Killing the $packageArgs['softwareExe'] process...
    Stop-Process -ProcessName $packageArgs['softwareExe']
    Uninstall-ChocolateyPackage  @packageArgs
  }
} elseif ($key.Count -eq 0) {
  Write-Warning "$packageName has already been uninstalled by other means."
} elseif ($key.Count -gt 1) {
  Write-Warning "$key.Count matches found!"
  Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
  Write-Warning "Please alert package maintainer the following keys were matched:"
  $key | % {Write-Warning "- $_.DisplayName"}
}
