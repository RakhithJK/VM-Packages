$ErrorActionPreference = 'Stop'
Import-Module vm.common -Force -DisableNameChecking

try {
  # Iterate through C:\Windows\System32 downloading all PDBs concurrently
  $executablePath = Join-Path ${Env:RAW_TOOLS_DIR} PDBReSym\PDBReSym.exe -Resolve
  VM-Write-Log "INFO" "Iterating through C:\Windows\System32 downloading PDBs to C:\symbols"
  & $executablePath cachesyms
  # The downloaded symbols are store into C:\symbols
  VM-Assert-Path "C:\symbols"
} catch {
  VM-Write-Log-Exception $_
}
