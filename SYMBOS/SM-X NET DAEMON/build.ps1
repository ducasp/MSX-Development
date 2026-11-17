# Build script for the SymbOS Network Daemon - OCM Wi-Fi driver
# (based on https://github.com/Jzzy-dev/msx-picoverse-symbos-network-daemon)
#
# Uses sjasmplus (WinAPE-compatible relocate_* directives).
# sjasmplus is not shipped in this repository - see README.md for the
# download link. Put sjasmplus.exe either on the PATH or into
# tools\sjasmplus\sjasmplus.exe (that folder is git-ignored).
#
# Output: netd-ocm.exe
$ErrorActionPreference = "Stop"

$sj = Join-Path $PSScriptRoot "tools\sjasmplus\sjasmplus.exe"
if (-not (Test-Path $sj)) {
    $cmd = Get-Command sjasmplus -ErrorAction SilentlyContinue
    if ($cmd) { $sj = $cmd.Source }
}
if (-not $sj -or -not (Test-Path $sj)) {
    Write-Error "sjasmplus not found. Download it from https://github.com/z00m128/sjasmplus/releases (tested with v1.24.0) and copy sjasmplus.exe to tools\sjasmplus\sjasmplus.exe, or add it to the PATH."
}

& $sj --nologo --sym="netd-ocm.sym" "Dmn-Network-_OcmWifi-sj.asm"
if ($LASTEXITCODE -ne 0) { Write-Error "assembly failed" }

Write-Output "OK: netd-ocm.exe ($((Get-Item (Join-Path $PSScriptRoot 'netd-ocm.exe')).Length) bytes, symbols in netd-ocm.sym)"
