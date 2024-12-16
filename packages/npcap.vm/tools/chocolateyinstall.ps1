$ErrorActionPreference = 'Stop'
Import-Module vm.common -Force -DisableNameChecking

try {
    $exeUrl = 'https://npcap.com/dist/npcap-1.80.exe'
    $exeSha256 = 'ac4f26d7d9f994d6f04141b2266f02682def51af63c09c96a7268552c94a6535'
    $installerName = Split-Path -Path $exeUrl -Leaf

    $packageArgs = @{
        packageName   = ${Env:ChocolateyPackageName}
        url           = $exeUrl
        checksum      = $exeSha256
        checksumType  = "sha256"
        fileFullPath  = Join-Path ${Env:TEMP} $installerName
    }
    Get-ChocolateyWebFile @packageArgs
    VM-Assert-Path $packageArgs.fileFullPath

    $ahkInstaller = Join-Path $(Split-Path $MyInvocation.MyCommand.Definition) "install.ahk" -Resolve
    $process = Start-Process -FilePath $ahkInstaller -ArgumentList $packageArgs.fileFullPath -PassThru
    # Wait for the AutoHotKey script to finish. We need a max time as if something goes wrong
    # (for example the installation takes longer than exception), it will never finish.
    $process.WaitForExit(600000)
    if ($process.ExitCode -eq 1) {
        throw "AutoHotKey returned a failure exit code ($rc) for: ${Env:ChocolateyPackageName}"
    } else {
        VM-Assert-Path $(Join-Path ${Env:PROGRAMFILES} "Npcap\npcap.cat")
    }
} catch {
    VM-Write-Log-Exception $_
}

