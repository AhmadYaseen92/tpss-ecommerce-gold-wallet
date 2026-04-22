using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GoldWalletSystem.Infrastructure.Database.Migrations
{
    public partial class AddWalletAssetStableFields : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "AcquisitionDiscountAmount",
                table: "WalletAssets",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "AcquisitionFeesAmount",
                table: "WalletAssets",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "AcquisitionFinalAmount",
                table: "WalletAssets",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "AcquisitionSubTotalAmount",
                table: "WalletAssets",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<string>(
                name: "FormType",
                table: "WalletAssets",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int?>(
                name: "LastTransactionHistoryId",
                table: "WalletAssets",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MaterialType",
                table: "WalletAssets",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int?>(
                name: "ProductId",
                table: "WalletAssets",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ProductImageUrl",
                table: "WalletAssets",
                type: "nvarchar(1000)",
                maxLength: 1000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ProductName",
                table: "WalletAssets",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "ProductSku",
                table: "WalletAssets",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PurityDisplayName",
                table: "WalletAssets",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PurityKarat",
                table: "WalletAssets",
                type: "nvarchar(30)",
                maxLength: 30,
                nullable: true);

            migrationBuilder.AddColumn<int?>(
                name: "SourceInvoiceId",
                table: "WalletAssets",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "WeightValue",
                table: "WalletAssets",
                type: "decimal(18,3)",
                precision: 18,
                scale: 3,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<string>(
                name: "WeightUnit",
                table: "WalletAssets",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "gram");

            migrationBuilder.CreateIndex(
                name: "IX_WalletAssets_LastTransactionHistoryId",
                table: "WalletAssets",
                column: "LastTransactionHistoryId");

            migrationBuilder.CreateIndex(
                name: "IX_WalletAssets_ProductId",
                table: "WalletAssets",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_WalletAssets_SourceInvoiceId",
                table: "WalletAssets",
                column: "SourceInvoiceId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_WalletAssets_LastTransactionHistoryId",
                table: "WalletAssets");

            migrationBuilder.DropIndex(
                name: "IX_WalletAssets_ProductId",
                table: "WalletAssets");

            migrationBuilder.DropIndex(
                name: "IX_WalletAssets_SourceInvoiceId",
                table: "WalletAssets");

            migrationBuilder.DropColumn(name: "AcquisitionDiscountAmount", table: "WalletAssets");
            migrationBuilder.DropColumn(name: "AcquisitionFeesAmount", table: "WalletAssets");
            migrationBuilder.DropColumn(name: "AcquisitionFinalAmount", table: "WalletAssets");
            migrationBuilder.DropColumn(name: "AcquisitionSubTotalAmount", table: "WalletAssets");
            migrationBuilder.DropColumn(name: "FormType", table: "WalletAssets");
            migrationBuilder.DropColumn(name: "LastTransactionHistoryId", table: "WalletAssets");
            migrationBuilder.DropColumn(name: "MaterialType", table: "WalletAssets");
            migrationBuilder.DropColumn(name: "ProductId", table: "WalletAssets");
            migrationBuilder.DropColumn(name: "ProductImageUrl", table: "WalletAssets");
            migrationBuilder.DropColumn(name: "ProductName", table: "WalletAssets");
            migrationBuilder.DropColumn(name: "ProductSku", table: "WalletAssets");
            migrationBuilder.DropColumn(name: "PurityDisplayName", table: "WalletAssets");
            migrationBuilder.DropColumn(name: "PurityKarat", table: "WalletAssets");
            migrationBuilder.DropColumn(name: "SourceInvoiceId", table: "WalletAssets");
            migrationBuilder.DropColumn(name: "WeightUnit", table: "WalletAssets");
            migrationBuilder.DropColumn(name: "WeightValue", table: "WalletAssets");
        }
    }
}
