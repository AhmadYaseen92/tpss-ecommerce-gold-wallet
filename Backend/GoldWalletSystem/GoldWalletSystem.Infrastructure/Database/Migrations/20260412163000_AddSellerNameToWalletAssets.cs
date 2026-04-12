using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GoldWalletSystem.Infrastructure.Database.Migrations
{
    public partial class AddSellerNameToWalletAssets : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "SellerName",
                table: "WalletAssets",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: false,
                defaultValue: "");

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
            migrationBuilder.DropColumn(
                name: "SellerName",
                table: "WalletAssets");
        }
    }
}
