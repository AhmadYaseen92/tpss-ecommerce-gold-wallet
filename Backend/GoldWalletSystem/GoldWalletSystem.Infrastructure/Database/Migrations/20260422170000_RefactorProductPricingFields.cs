using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GoldWalletSystem.Infrastructure.Database.Migrations;

public partial class RefactorProductPricingFields : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.RenameColumn(
            name: "ManualSellPrice",
            table: "Products",
            newName: "FixedPrice");

        migrationBuilder.AddColumn<decimal>(
            name: "AutoPrice",
            table: "Products",
            type: "decimal(18,2)",
            precision: 18,
            scale: 2,
            nullable: false,
            defaultValue: 0m);

        migrationBuilder.AddColumn<decimal>(
            name: "SellPrice",
            table: "Products",
            type: "decimal(18,2)",
            precision: 18,
            scale: 2,
            nullable: false,
            defaultValue: 0m);

        migrationBuilder.Sql(@"
            UPDATE P
            SET AutoPrice = CASE
                    WHEN PricingMode = 1 THEN BaseMarketPrice * WeightValue * CASE WHEN PurityFactor > 0 THEN PurityFactor ELSE 1 END
                    ELSE 0
                END,
                SellPrice = CASE
                    WHEN OfferType = 1 AND OfferPercent > 0
                        THEN (CASE WHEN PricingMode = 1 THEN BaseMarketPrice * WeightValue * CASE WHEN PurityFactor > 0 THEN PurityFactor ELSE 1 END ELSE FixedPrice END) * (1 - (OfferPercent / 100.0))
                    WHEN OfferType = 2 AND OfferNewPrice > 0
                        THEN OfferNewPrice
                    ELSE (CASE WHEN PricingMode = 1 THEN BaseMarketPrice * WeightValue * CASE WHEN PurityFactor > 0 THEN PurityFactor ELSE 1 END ELSE FixedPrice END)
                END
            FROM Products P;");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropColumn(
            name: "AutoPrice",
            table: "Products");

        migrationBuilder.DropColumn(
            name: "SellPrice",
            table: "Products");

        migrationBuilder.RenameColumn(
            name: "FixedPrice",
            table: "Products",
            newName: "ManualSellPrice");
    }
}
