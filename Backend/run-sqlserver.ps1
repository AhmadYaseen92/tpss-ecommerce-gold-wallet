param(
  [string]$Server = "localhost",
  [string]$Database = "GoldWalletDb"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$runner = Join-Path $root "scripts/windows-sqlserver-migrate-and-run.ps1"

& $runner -Server $Server -Database $Database
