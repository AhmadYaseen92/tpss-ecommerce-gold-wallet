using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GoldWalletSystem.Infrastructure.Database.Migrations
{
    public partial class FeeSchemaCleanup : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(name: "DeliveryFee", table: "Products");
            migrationBuilder.DropColumn(name: "StorageFee", table: "Products");
            migrationBuilder.DropColumn(name: "ServiceCharge", table: "Products");
            migrationBuilder.DropColumn(name: "Price", table: "Products");

            migrationBuilder.AddColumn<bool>(
                name: "IsAdminManaged",
                table: "SystemFeeTypes",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "Currency",
                table: "TransactionFeeBreakdowns",
                type: "nvarchar(10)",
                maxLength: 10,
                nullable: false,
                defaultValue: "USD");

            migrationBuilder.AddColumn<string>(
                name: "SourceType",
                table: "TransactionFeeBreakdowns",
                type: "nvarchar(80)",
                maxLength: 80,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "ConfigSnapshotJson",
                table: "TransactionFeeBreakdowns",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "ProductId",
                table: "TransactionHistories",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "SubTotalAmount",
                table: "TransactionHistories",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "TotalFeesAmount",
                table: "TransactionHistories",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "DiscountAmount",
                table: "TransactionHistories",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "FinalAmount",
                table: "TransactionHistories",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.CreateIndex(
                name: "IX_TransactionHistories_ProductId",
                table: "TransactionHistories",
                column: "ProductId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(name: "IX_TransactionHistories_ProductId", table: "TransactionHistories");

            migrationBuilder.DropColumn(name: "IsAdminManaged", table: "SystemFeeTypes");
            migrationBuilder.DropColumn(name: "Currency", table: "TransactionFeeBreakdowns");
            migrationBuilder.DropColumn(name: "SourceType", table: "TransactionFeeBreakdowns");
            migrationBuilder.DropColumn(name: "ConfigSnapshotJson", table: "TransactionFeeBreakdowns");
            migrationBuilder.DropColumn(name: "ProductId", table: "TransactionHistories");
            migrationBuilder.DropColumn(name: "SubTotalAmount", table: "TransactionHistories");
            migrationBuilder.DropColumn(name: "TotalFeesAmount", table: "TransactionHistories");
            migrationBuilder.DropColumn(name: "DiscountAmount", table: "TransactionHistories");
            migrationBuilder.DropColumn(name: "FinalAmount", table: "TransactionHistories");

            migrationBuilder.AddColumn<decimal>(
                name: "DeliveryFee",
                table: "Products",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "StorageFee",
                table: "Products",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "ServiceCharge",
                table: "Products",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "Price",
                table: "Products",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);
        }
    }
}
