using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GoldWalletSystem.Infrastructure.Database.Migrations
{
    public partial class SeedPortfolioData : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
DECLARE @Now datetime2 = SYSUTCDATETIME();

INSERT INTO [Wallets] ([UserId], [CashBalance], [CurrencyCode], [CreatedAtUtc], [UpdatedAtUtc])
SELECT U.[Id], 10000.00, N'USD', @Now, @Now
FROM [Users] U
WHERE NOT EXISTS (SELECT 1 FROM [Wallets] W WHERE W.[UserId] = U.[Id]);

;WITH SeedAssets AS
(
    SELECT W.[Id] AS WalletId, 1 AS AssetType, CAST(100.000 AS decimal(18,3)) AS Weight, N'gram' AS Unit, CAST(24.00 AS decimal(5,2)) AS Purity, 1 AS Quantity, CAST(6200.00 AS decimal(18,2)) AS AverageBuyPrice, CAST(6400.00 AS decimal(18,2)) AS CurrentMarketPrice
    FROM [Wallets] W
    UNION ALL
    SELECT W.[Id], 5, CAST(250.000 AS decimal(18,3)), N'gram', CAST(99.90 AS decimal(5,2)), 1, CAST(220.00 AS decimal(18,2)), CAST(235.00 AS decimal(18,2))
    FROM [Wallets] W
    UNION ALL
    SELECT W.[Id], 6, CAST(30.000 AS decimal(18,3)), N'gram', CAST(18.00 AS decimal(5,2)), 2, CAST(1500.00 AS decimal(18,2)), CAST(1650.00 AS decimal(18,2))
    FROM [Wallets] W
)
INSERT INTO [WalletAssets] ([WalletId], [AssetType], [Weight], [Unit], [Purity], [Quantity], [AverageBuyPrice], [CurrentMarketPrice], [CreatedAtUtc], [UpdatedAtUtc])
SELECT S.[WalletId], S.[AssetType], S.[Weight], S.[Unit], S.[Purity], S.[Quantity], S.[AverageBuyPrice], S.[CurrentMarketPrice], @Now, @Now
FROM SeedAssets S
WHERE NOT EXISTS (SELECT 1 FROM [WalletAssets] WA WHERE WA.[WalletId] = S.[WalletId] AND WA.[AssetType] = S.[AssetType]);
""");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Keep seeded portfolio rows for auditability and data continuity.
        }
    }
}
