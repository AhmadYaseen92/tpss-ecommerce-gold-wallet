using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GoldWalletSystem.Infrastructure.Database.Migrations
{
    public partial class AddFeeManagementTables : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "AdminTransactionFees",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FeeCode = table.Column<string>(type: "nvarchar(80)", maxLength: 80, nullable: false),
                    IsEnabled = table.Column<bool>(type: "bit", nullable: false),
                    CalculationMode = table.Column<string>(type: "nvarchar(40)", maxLength: 40, nullable: false),
                    RatePercent = table.Column<decimal>(type: "decimal(18,6)", precision: 18, scale: 6, nullable: true),
                    FixedAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: true),
                    AppliesToBuy = table.Column<bool>(type: "bit", nullable: false),
                    AppliesToSell = table.Column<bool>(type: "bit", nullable: false),
                    AppliesToPickup = table.Column<bool>(type: "bit", nullable: false),
                    AppliesToTransfer = table.Column<bool>(type: "bit", nullable: false),
                    AppliesToGift = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AdminTransactionFees", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "SystemFeeTypes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FeeCode = table.Column<string>(type: "nvarchar(80)", maxLength: 80, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    IsEnabled = table.Column<bool>(type: "bit", nullable: false),
                    AppliesToBuy = table.Column<bool>(type: "bit", nullable: false),
                    AppliesToSell = table.Column<bool>(type: "bit", nullable: false),
                    AppliesToPickup = table.Column<bool>(type: "bit", nullable: false),
                    AppliesToTransfer = table.Column<bool>(type: "bit", nullable: false),
                    AppliesToGift = table.Column<bool>(type: "bit", nullable: false),
                    AppliesToInvoice = table.Column<bool>(type: "bit", nullable: false),
                    AppliesToReports = table.Column<bool>(type: "bit", nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SystemFeeTypes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "TransactionFeeBreakdowns",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TransactionHistoryId = table.Column<int>(type: "int", nullable: true),
                    WalletActionId = table.Column<int>(type: "int", nullable: true),
                    ProductId = table.Column<int>(type: "int", nullable: true),
                    SellerId = table.Column<int>(type: "int", nullable: true),
                    FeeCode = table.Column<string>(type: "nvarchar(80)", maxLength: 80, nullable: false),
                    FeeName = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: false),
                    CalculationMode = table.Column<string>(type: "nvarchar(80)", maxLength: 80, nullable: false),
                    BaseAmount = table.Column<decimal>(type: "decimal(18,6)", precision: 18, scale: 6, nullable: false),
                    Quantity = table.Column<decimal>(type: "decimal(18,6)", precision: 18, scale: 6, nullable: false),
                    AppliedRate = table.Column<decimal>(type: "decimal(18,6)", precision: 18, scale: 6, nullable: true),
                    AppliedValue = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    IsDiscount = table.Column<bool>(type: "bit", nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TransactionFeeBreakdowns", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "SellerProductFees",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SellerId = table.Column<int>(type: "int", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: false),
                    FeeCode = table.Column<string>(type: "nvarchar(80)", maxLength: 80, nullable: false),
                    IsEnabled = table.Column<bool>(type: "bit", nullable: false),
                    CalculationMode = table.Column<string>(type: "nvarchar(80)", maxLength: 80, nullable: false),
                    RatePercent = table.Column<decimal>(type: "decimal(18,6)", precision: 18, scale: 6, nullable: true),
                    MinimumAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: true),
                    FlatAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: true),
                    PremiumDiscountType = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: true),
                    ValuePerUnit = table.Column<decimal>(type: "decimal(18,6)", precision: 18, scale: 6, nullable: true),
                    FeePercent = table.Column<decimal>(type: "decimal(18,6)", precision: 18, scale: 6, nullable: true),
                    GracePeriodDays = table.Column<int>(type: "int", nullable: true),
                    FixedAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: true),
                    FeePerUnit = table.Column<decimal>(type: "decimal(18,6)", precision: 18, scale: 6, nullable: true),
                    IsOverride = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SellerProductFees", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SellerProductFees_Products_ProductId",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_SellerProductFees_Sellers_SellerId",
                        column: x => x.SellerId,
                        principalTable: "Sellers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AdminTransactionFees_FeeCode",
                table: "AdminTransactionFees",
                column: "FeeCode",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_SellerProductFees_ProductId",
                table: "SellerProductFees",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_SellerProductFees_SellerId",
                table: "SellerProductFees",
                column: "SellerId");

            migrationBuilder.CreateIndex(
                name: "IX_SellerProductFees_SellerId_ProductId_FeeCode",
                table: "SellerProductFees",
                columns: new[] { "SellerId", "ProductId", "FeeCode" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_SystemFeeTypes_FeeCode",
                table: "SystemFeeTypes",
                column: "FeeCode",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_TransactionFeeBreakdowns_FeeCode_CreatedAtUtc",
                table: "TransactionFeeBreakdowns",
                columns: new[] { "FeeCode", "CreatedAtUtc" });

            migrationBuilder.CreateIndex(
                name: "IX_TransactionFeeBreakdowns_TransactionHistoryId",
                table: "TransactionFeeBreakdowns",
                column: "TransactionHistoryId");

            migrationBuilder.CreateIndex(
                name: "IX_TransactionFeeBreakdowns_WalletActionId",
                table: "TransactionFeeBreakdowns",
                column: "WalletActionId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(name: "AdminTransactionFees");
            migrationBuilder.DropTable(name: "SellerProductFees");
            migrationBuilder.DropTable(name: "SystemFeeTypes");
            migrationBuilder.DropTable(name: "TransactionFeeBreakdowns");
        }
    }
}
