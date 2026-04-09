param(
  [string]$Server = "localhost",
  [string]$Database = "GoldWalletDb"
)

$scriptPath = Join-Path $PSScriptRoot "../scripts/windows-sqlserver-migrate-and-run.ps1"
& $scriptPath -Server $Server -Database $Database
