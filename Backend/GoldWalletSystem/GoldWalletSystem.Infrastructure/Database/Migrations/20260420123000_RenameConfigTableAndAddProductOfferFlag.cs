using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GoldWalletSystem.Infrastructure.Database.Migrations
{
    public partial class RenameConfigTableAndAddProductOfferFlag : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameTable(
                name: "MobileAppConfigurations",
                newName: "SystemConfigration");

            migrationBuilder.RenameIndex(
                name: "IX_MobileAppConfigurations_ConfigKey",
                table: "SystemConfigration",
                newName: "IX_SystemConfigration_ConfigKey");

            migrationBuilder.AddColumn<bool>(
                name: "IsHasOffer",
                table: "Products",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.Sql(@"
UPDATE Products
SET IsHasOffer = CASE WHEN OfferType <> 0 THEN 1 ELSE 0 END;");

            migrationBuilder.Sql(@"
DELETE FROM SystemConfigration
WHERE ConfigKey IN (N'MobileRelease_AllSellersLabel', N'home.carousel.images');");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsHasOffer",
                table: "Products");

            migrationBuilder.RenameIndex(
                name: "IX_SystemConfigration_ConfigKey",
                table: "SystemConfigration",
                newName: "IX_MobileAppConfigurations_ConfigKey");

            migrationBuilder.RenameTable(
                name: "SystemConfigration",
                newName: "MobileAppConfigurations");
        }
    }
}
