using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GoldWalletSystem.Infrastructure.Database.Migrations
{
    public partial class RefactorInvoiceForWalletInvestorSeller : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Currency",
                table: "Invoices",
                type: "nvarchar(10)",
                maxLength: 10,
                nullable: false,
                defaultValue: "USD");

            migrationBuilder.AddColumn<decimal>(
                name: "DiscountAmount",
                table: "Invoices",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<string>(
                name: "ExternalReference",
                table: "Invoices",
                type: "nvarchar(120)",
                maxLength: 120,
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "FeesAmount",
                table: "Invoices",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<DateTime>(
                name: "PaidOnUtc",
                table: "Invoices",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PaymentMethod",
                table: "Invoices",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "Unknown");

            migrationBuilder.AddColumn<string>(
                name: "PaymentStatus",
                table: "Invoices",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "Pending");

            migrationBuilder.AddColumn<string>(
                name: "PaymentTransactionId",
                table: "Invoices",
                type: "nvarchar(120)",
                maxLength: 120,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PdfUrl",
                table: "Invoices",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ProductId",
                table: "Invoices",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "WalletItemId",
                table: "Invoices",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "InvoiceId",
                table: "TransactionHistories",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "WalletItemId",
                table: "TransactionHistories",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "Purity",
                table: "InvoiceItems",
                type: "decimal(5,2)",
                precision: 5,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<int>(
                name: "WalletItemId",
                table: "InvoiceItems",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "Weight",
                table: "InvoiceItems",
                type: "decimal(18,3)",
                precision: 18,
                scale: 3,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.RenameColumn(
                name: "LineTotal",
                table: "InvoiceItems",
                newName: "TotalPrice");

            migrationBuilder.RenameColumn(
                name: "ItemName",
                table: "InvoiceItems",
                newName: "ProductName");

            migrationBuilder.DropColumn(
                name: "ItemQrCode",
                table: "InvoiceItems");

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_PaymentStatus",
                table: "Invoices",
                column: "PaymentStatus");

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_ProductId",
                table: "Invoices",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_WalletItemId",
                table: "Invoices",
                column: "WalletItemId");

            migrationBuilder.CreateIndex(
                name: "IX_TransactionHistories_InvoiceId",
                table: "TransactionHistories",
                column: "InvoiceId");

            migrationBuilder.CreateIndex(
                name: "IX_TransactionHistories_WalletItemId",
                table: "TransactionHistories",
                column: "WalletItemId");

            migrationBuilder.CreateIndex(
                name: "IX_InvoiceItems_WalletItemId",
                table: "InvoiceItems",
                column: "WalletItemId");

            migrationBuilder.AddForeignKey(
                name: "FK_InvoiceItems_WalletAssets_WalletItemId",
                table: "InvoiceItems",
                column: "WalletItemId",
                principalTable: "WalletAssets",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_Invoices_Products_ProductId",
                table: "Invoices",
                column: "ProductId",
                principalTable: "Products",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_Invoices_WalletAssets_WalletItemId",
                table: "Invoices",
                column: "WalletItemId",
                principalTable: "WalletAssets",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_TransactionHistories_Invoices_InvoiceId",
                table: "TransactionHistories",
                column: "InvoiceId",
                principalTable: "Invoices",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_TransactionHistories_WalletAssets_WalletItemId",
                table: "TransactionHistories",
                column: "WalletItemId",
                principalTable: "WalletAssets",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.Sql("UPDATE Invoices SET Status = 'Issued' WHERE Status IN ('Generated','approved','pending') OR Status IS NULL");
            migrationBuilder.Sql("UPDATE Invoices SET InvoiceCategory = 'Sell' WHERE LOWER(InvoiceCategory) = 'sell'");
            migrationBuilder.Sql("UPDATE Invoices SET InvoiceCategory = 'Transfer' WHERE LOWER(InvoiceCategory) = 'transfer'");
            migrationBuilder.Sql("UPDATE Invoices SET InvoiceCategory = 'Gift' WHERE LOWER(InvoiceCategory) = 'gift'");
            migrationBuilder.Sql("UPDATE Invoices SET InvoiceCategory = 'Pickup' WHERE LOWER(InvoiceCategory) IN ('pickup','certificate','invoice')");
            migrationBuilder.Sql("UPDATE Invoices SET InvoiceCategory = 'Buy' WHERE InvoiceCategory IS NULL OR LTRIM(RTRIM(InvoiceCategory)) = '' OR InvoiceCategory NOT IN ('Buy','Sell','Transfer','Gift','Pickup')");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(name: "FK_InvoiceItems_WalletAssets_WalletItemId", table: "InvoiceItems");
            migrationBuilder.DropForeignKey(name: "FK_Invoices_Products_ProductId", table: "Invoices");
            migrationBuilder.DropForeignKey(name: "FK_Invoices_WalletAssets_WalletItemId", table: "Invoices");
            migrationBuilder.DropForeignKey(name: "FK_TransactionHistories_Invoices_InvoiceId", table: "TransactionHistories");
            migrationBuilder.DropForeignKey(name: "FK_TransactionHistories_WalletAssets_WalletItemId", table: "TransactionHistories");

            migrationBuilder.DropIndex(name: "IX_Invoices_PaymentStatus", table: "Invoices");
            migrationBuilder.DropIndex(name: "IX_Invoices_ProductId", table: "Invoices");
            migrationBuilder.DropIndex(name: "IX_Invoices_WalletItemId", table: "Invoices");
            migrationBuilder.DropIndex(name: "IX_TransactionHistories_InvoiceId", table: "TransactionHistories");
            migrationBuilder.DropIndex(name: "IX_TransactionHistories_WalletItemId", table: "TransactionHistories");
            migrationBuilder.DropIndex(name: "IX_InvoiceItems_WalletItemId", table: "InvoiceItems");

            migrationBuilder.RenameColumn(name: "ProductName", table: "InvoiceItems", newName: "ItemName");
            migrationBuilder.RenameColumn(name: "TotalPrice", table: "InvoiceItems", newName: "LineTotal");

            migrationBuilder.DropColumn(name: "Currency", table: "Invoices");
            migrationBuilder.DropColumn(name: "DiscountAmount", table: "Invoices");
            migrationBuilder.DropColumn(name: "ExternalReference", table: "Invoices");
            migrationBuilder.DropColumn(name: "FeesAmount", table: "Invoices");
            migrationBuilder.DropColumn(name: "PaidOnUtc", table: "Invoices");
            migrationBuilder.DropColumn(name: "PaymentMethod", table: "Invoices");
            migrationBuilder.DropColumn(name: "PaymentStatus", table: "Invoices");
            migrationBuilder.DropColumn(name: "PaymentTransactionId", table: "Invoices");
            migrationBuilder.DropColumn(name: "PdfUrl", table: "Invoices");
            migrationBuilder.DropColumn(name: "ProductId", table: "Invoices");
            migrationBuilder.DropColumn(name: "WalletItemId", table: "Invoices");

            migrationBuilder.DropColumn(name: "InvoiceId", table: "TransactionHistories");
            migrationBuilder.DropColumn(name: "WalletItemId", table: "TransactionHistories");

            migrationBuilder.DropColumn(name: "Purity", table: "InvoiceItems");
            migrationBuilder.DropColumn(name: "WalletItemId", table: "InvoiceItems");
            migrationBuilder.DropColumn(name: "Weight", table: "InvoiceItems");

            migrationBuilder.AddColumn<string>(
                name: "ItemQrCode",
                table: "InvoiceItems",
                type: "nvarchar(300)",
                maxLength: 300,
                nullable: false,
                defaultValue: "");
        }
    }
}
