$ErrorActionPreference = 'Continue'
Import-Module FireEyeVM.common -Force -DisableNameChecking

function LoadPackages {
  try {
    $json = Get-Content $pkgPath -ErrorAction Stop
    $packages = FE-ConvertFrom-Json $json
  } catch {
    return $null
  }
  return $packages
}

function InstallOneModule {
  param([hashtable] $module)
  $name = $module.name
  if ($null -eq $module.url) {
    $url = $name
  } else {
    $url = $module.url
  }
  iex "py -2 -m pip install $url 2>&1 >> $outputFile"
  return $LastExitCode
}

$toolDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$pkgPath = Join-Path $toolDir "packages.json"

$json = LoadPackages $pkgPath
if (($null -eq $json) -Or ($null -eq $json.packages)) {
  Write-Host "Error loading Python2 packages! Exiting"
  Exit 1
}

# Create output file to log python module installation details
$outputFile = FE-New-Install-Log $toolDir

# upgrade pip
iex "py -2 -m pip install -qq --no-cache-dir --upgrade pip 2>&1 >> $outputFile"

$packages = $json.packages
$success = $true
foreach ($pkg in $packages) {
  $name = $pkg.name
  Write-Host "Trying to install $name"
  if ((InstallOneModule $pkg) -eq 0) {
    Write-Host "Installed $name"
  } else {
    FE-Write-Log "ERROR" "Failed to install $name"
    $success = $false
  }
}

if ($success -eq $false) {
  Write-Host "Failed to install at least one Python module"
  FE-Write-Log "ERROR" "Check $outputFile for more information"
  Exit 1
}