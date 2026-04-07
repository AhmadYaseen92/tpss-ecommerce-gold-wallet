param(
  [string]$Server = "localhost",
  [string]$Database = "GoldWalletDb",
  [switch]$TrustedConnection = $true,
  [string]$SqlUser = "",
  [string]$SqlPassword = "",
  [switch]$AddMigration,
  [string]$MigrationName = "InitialSqlServer"
)

$ErrorActionPreference = "Stop"

function Invoke-Dotnet {
  param([string]$Args)
  Write-Host "> dotnet $Args"
  & dotnet $Args
  if ($LASTEXITCODE -ne 0) {
    throw "dotnet command failed: dotnet $Args"
  }
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$api = Join-Path $scriptDir "../TPSS.GoldWallet.Api"
Set-Location $api

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
  throw "dotnet SDK is required."
}

if ($TrustedConnection) {
  $conn = "Server=$Server;Database=$Database;Trusted_Connection=True;TrustServerCertificate=True;"
}
else {
  if ([string]::IsNullOrWhiteSpace($SqlUser) -or [string]::IsNullOrWhiteSpace($SqlPassword)) {
    throw "Provide -SqlUser and -SqlPassword when TrustedConnection is disabled."
  }
  $conn = "Server=$Server;Database=$Database;User Id=$SqlUser;Password=$SqlPassword;TrustServerCertificate=True;"
}

$env:ConnectionStrings__SqlServer = $conn
$env:ASPNETCORE_ENVIRONMENT = "Development"

Write-Host "[1/3] Restoring packages..."
Invoke-Dotnet "restore"

if ($AddMigration) {
  Write-Host "[2/4] Adding migration $MigrationName..."
  Invoke-Dotnet "ef migrations add $MigrationName --project ../TPSS.GoldWallet.Infrastructure --startup-project . --output-dir Persistence/Migrations"

  Write-Host "[3/4] Applying migrations..."
  Invoke-Dotnet "ef database update --project ../TPSS.GoldWallet.Infrastructure --startup-project ."

  Write-Host "[4/4] Running API..."
  Invoke-Dotnet "run"
}
else {
  Write-Host "[2/3] Applying migrations..."
  Invoke-Dotnet "ef database update --project ../TPSS.GoldWallet.Infrastructure --startup-project ."

  Write-Host "[3/3] Running API..."
  Invoke-Dotnet "run"
}
