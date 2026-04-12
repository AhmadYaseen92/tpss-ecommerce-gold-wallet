using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GoldWalletSystem.Infrastructure.Database.Migrations
{
    public partial class AddSellerNameToWalletAssets : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
IF COL_LENGTH('WalletAssets', 'SellerName') IS NULL
BEGIN
    ALTER TABLE [WalletAssets]
    ADD [SellerName] nvarchar(200) NOT NULL
        CONSTRAINT [DF_WalletAssets_SellerName] DEFAULT N'';
END
""");

            migrationBuilder.Sql("""
UPDATE [WalletAssets]
SET [SellerName] = CASE
    WHEN [AssetType] = 5 THEN N'Bullion House'
    WHEN [AssetType] = 6 THEN N'Gold Palace'
    ELSE N'Imseeh'
END
WHERE [SellerName] = N'';
""");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
IF COL_LENGTH('WalletAssets', 'SellerName') IS NOT NULL
BEGIN
    ALTER TABLE [WalletAssets] DROP CONSTRAINT [DF_WalletAssets_SellerName];
    ALTER TABLE [WalletAssets] DROP COLUMN [SellerName];
END
""");
        }
    }
}