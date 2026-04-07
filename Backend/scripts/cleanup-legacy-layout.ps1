$ErrorActionPreference = "Stop"

$backend = Split-Path -Parent $MyInvocation.MyCommand.Path
$legacySrc = Join-Path $backend "../src"

if (Test-Path $legacySrc) {
    Write-Host "Removing legacy folder: $legacySrc"
    Remove-Item -Path $legacySrc -Recurse -Force
}

Get-ChildItem -Path (Join-Path $backend "..") -Recurse -Directory -Filter bin | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path (Join-Path $backend "..") -Recurse -Directory -Filter obj | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Done. Open Backend/TPSS.GoldWallet.sln in Visual Studio (not VS Code Explorer) to get project right-click actions (Build/Clean/Publish)."
