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
