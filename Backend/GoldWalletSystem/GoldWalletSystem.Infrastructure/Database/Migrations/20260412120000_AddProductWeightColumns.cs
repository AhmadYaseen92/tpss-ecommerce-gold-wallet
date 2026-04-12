using GoldWalletSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GoldWalletSystem.Infrastructure.Database.Migrations
{
    public partial class AddProductWeightColumns : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "WeightValue",
                table: "Products",
                type: "decimal(18,3)",
                precision: 18,
                scale: 3,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<int>(
                name: "WeightUnit",
                table: "Products",
                type: "int",
                nullable: false,
                defaultValue: (int)ProductWeightUnit.Gram);

            migrationBuilder.Sql("""
UPDATE [Products]
SET [WeightValue] = CASE
        WHEN LOWER([Name]) LIKE '%1 kg%' THEN 1
        WHEN LOWER([Name]) LIKE '%100 g%' THEN 100
        WHEN LOWER([Name]) LIKE '%50 g%' THEN 50
        WHEN LOWER([Name]) LIKE '%20 g%' THEN 20
        WHEN LOWER([Name]) LIKE '%10 g%' THEN 10
        WHEN LOWER([Name]) LIKE '%5 g%' THEN 5
        WHEN LOWER([Name]) LIKE '%1 oz%' THEN 1
        ELSE [WeightValue]
    END,
    [WeightUnit] = CASE
        WHEN LOWER([Name]) LIKE '%kg%' THEN 2
        WHEN LOWER([Name]) LIKE '%oz%' THEN 3
        ELSE 1
    END
WHERE [WeightValue] = 0;
""");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "WeightValue",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "WeightUnit",
                table: "Products");
        }
    }
}
