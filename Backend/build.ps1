$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

dotnet clean TPSS.GoldWallet.sln
if ($LASTEXITCODE -ne 0) { throw "dotnet clean failed" }

dotnet build TPSS.GoldWallet.sln -c Debug
if ($LASTEXITCODE -ne 0) { throw "dotnet build failed" }

Write-Host "Build succeeded."
