using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GoldWalletSystem.Infrastructure.Database.Migrations
{
    public partial class InvoicesOnlyDropInvoiceItems : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ProductName",
                table: "Invoices",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "Quantity",
                table: "Invoices",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddColumn<decimal>(
                name: "UnitPrice",
                table: "Invoices",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "Weight",
                table: "Invoices",
                type: "decimal(18,3)",
                precision: 18,
                scale: 3,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "Purity",
                table: "Invoices",
                type: "decimal(5,2)",
                precision: 5,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<string>(
                name: "FromPartyType",
                table: "Invoices",
                type: "nvarchar(30)",
                maxLength: 30,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ToPartyType",
                table: "Invoices",
                type: "nvarchar(30)",
                maxLength: 30,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "FromPartyUserId",
                table: "Invoices",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ToPartyUserId",
                table: "Invoices",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "OwnershipEffectiveOnUtc",
                table: "Invoices",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "RelatedTransactionId",
                table: "Invoices",
                type: "int",
                nullable: true);

            migrationBuilder.Sql(@"
                UPDATE i
                SET
                    i.ProductName = ISNULL(ii.ProductName, i.ProductName),
                    i.Quantity = CASE WHEN ii.Quantity IS NULL OR ii.Quantity <= 0 THEN i.Quantity ELSE ii.Quantity END,
                    i.UnitPrice = CASE WHEN ii.UnitPrice IS NULL OR ii.UnitPrice <= 0 THEN i.UnitPrice ELSE ii.UnitPrice END,
                    i.Weight = CASE WHEN ii.Weight IS NULL THEN i.Weight ELSE ii.Weight END,
                    i.Purity = CASE WHEN ii.Purity IS NULL THEN i.Purity ELSE ii.Purity END
                FROM Invoices i
                INNER JOIN (
                    SELECT ii.InvoiceId,
                           ii.ProductName,
                           ii.Quantity,
                           ii.UnitPrice,
                           ii.Weight,
                           ii.Purity,
                           ROW_NUMBER() OVER (PARTITION BY ii.InvoiceId ORDER BY ii.Id ASC) AS rn
                    FROM InvoiceItems ii
                ) ii ON i.Id = ii.InvoiceId
                WHERE ii.rn = 1;
            ");

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_FromPartyUserId",
                table: "Invoices",
                column: "FromPartyUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_ToPartyUserId",
                table: "Invoices",
                column: "ToPartyUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_RelatedTransactionId",
                table: "Invoices",
                column: "RelatedTransactionId");

            migrationBuilder.AddForeignKey(
                name: "FK_Invoices_TransactionHistories_RelatedTransactionId",
                table: "Invoices",
                column: "RelatedTransactionId",
                principalTable: "TransactionHistories",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_Invoices_Users_FromPartyUserId",
                table: "Invoices",
                column: "FromPartyUserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_Invoices_Users_ToPartyUserId",
                table: "Invoices",
                column: "ToPartyUserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.DropTable(
                name: "InvoiceItems");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "InvoiceItems",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    InvoiceId = table.Column<int>(type: "int", nullable: false),
                    WalletItemId = table.Column<int>(type: "int", nullable: true),
                    ProductId = table.Column<int>(type: "int", nullable: false),
                    ProductName = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Quantity = table.Column<int>(type: "int", nullable: false),
                    UnitPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    Weight = table.Column<decimal>(type: "decimal(18,3)", precision: 18, scale: 3, nullable: false),
                    Purity = table.Column<decimal>(type: "decimal(5,2)", precision: 5, scale: 2, nullable: false),
                    TotalPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_InvoiceItems", x => x.Id);
                    table.ForeignKey(
                        name: "FK_InvoiceItems_Invoices_InvoiceId",
                        column: x => x.InvoiceId,
                        principalTable: "Invoices",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_InvoiceItems_Products_ProductId",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_InvoiceItems_WalletAssets_WalletItemId",
                        column: x => x.WalletItemId,
                        principalTable: "WalletAssets",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateIndex(
                name: "IX_InvoiceItems_InvoiceId_ProductId",
                table: "InvoiceItems",
                columns: new[] { "InvoiceId", "ProductId" });

            migrationBuilder.CreateIndex(
                name: "IX_InvoiceItems_ProductId",
                table: "InvoiceItems",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_InvoiceItems_WalletItemId",
                table: "InvoiceItems",
                column: "WalletItemId");

            migrationBuilder.DropForeignKey(name: "FK_Invoices_TransactionHistories_RelatedTransactionId", table: "Invoices");
            migrationBuilder.DropForeignKey(name: "FK_Invoices_Users_FromPartyUserId", table: "Invoices");
            migrationBuilder.DropForeignKey(name: "FK_Invoices_Users_ToPartyUserId", table: "Invoices");

            migrationBuilder.DropIndex(name: "IX_Invoices_FromPartyUserId", table: "Invoices");
            migrationBuilder.DropIndex(name: "IX_Invoices_ToPartyUserId", table: "Invoices");
            migrationBuilder.DropIndex(name: "IX_Invoices_RelatedTransactionId", table: "Invoices");

            migrationBuilder.DropColumn(name: "ProductName", table: "Invoices");
            migrationBuilder.DropColumn(name: "Quantity", table: "Invoices");
            migrationBuilder.DropColumn(name: "UnitPrice", table: "Invoices");
            migrationBuilder.DropColumn(name: "Weight", table: "Invoices");
            migrationBuilder.DropColumn(name: "Purity", table: "Invoices");
            migrationBuilder.DropColumn(name: "FromPartyType", table: "Invoices");
            migrationBuilder.DropColumn(name: "ToPartyType", table: "Invoices");
            migrationBuilder.DropColumn(name: "FromPartyUserId", table: "Invoices");
            migrationBuilder.DropColumn(name: "ToPartyUserId", table: "Invoices");
            migrationBuilder.DropColumn(name: "OwnershipEffectiveOnUtc", table: "Invoices");
            migrationBuilder.DropColumn(name: "RelatedTransactionId", table: "Invoices");
        }
    }
}
