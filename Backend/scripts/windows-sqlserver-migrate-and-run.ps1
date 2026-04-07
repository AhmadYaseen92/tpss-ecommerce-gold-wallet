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

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$api = Join-Path $root "../TPSS.GoldWallet.Api"
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

$env:Database__Provider = "SqlServer"
$env:ConnectionStrings__SqlServer = $conn
$env:ASPNETCORE_ENVIRONMENT = "Development"

Write-Host "[1/3] Restoring packages..."
dotnet restore

if ($AddMigration) {
  Write-Host "[2/4] Adding migration $MigrationName..."
  dotnet ef migrations add $MigrationName --project ../TPSS.GoldWallet.Infrastructure --startup-project . --output-dir Persistence/Migrations

  Write-Host "[3/4] Applying migrations..."
  dotnet ef database update --project ../TPSS.GoldWallet.Infrastructure --startup-project .

  Write-Host "[4/4] Running API..."
  dotnet run
}
else {
  Write-Host "[2/3] Applying migrations..."
  dotnet ef database update --project ../TPSS.GoldWallet.Infrastructure --startup-project .

  Write-Host "[3/3] Running API..."
  dotnet run
}
