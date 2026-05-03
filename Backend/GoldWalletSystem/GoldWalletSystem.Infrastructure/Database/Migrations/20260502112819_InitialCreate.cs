using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace GoldWalletSystem.Infrastructure.Database.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
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
                name: "SystemConfigration",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ConfigKey = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    ValueType = table.Column<int>(type: "int", nullable: false),
                    ValueBool = table.Column<bool>(type: "bit", nullable: true),
                    ValueInt = table.Column<int>(type: "int", nullable: true),
                    ValueDecimal = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: true),
                    ValueString = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SellerAccess = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SystemConfigration", x => x.Id);
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
                    IsAdminManaged = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
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
                    Currency = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false),
                    SourceType = table.Column<string>(type: "nvarchar(80)", maxLength: 80, nullable: false),
                    ConfigSnapshotJson = table.Column<string>(type: "nvarchar(max)", nullable: false),
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
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FullName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    Role = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    PhoneNumber = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "AppNotifications",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Type = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    ReferenceId = table.Column<int>(type: "int", nullable: true),
                    ReferenceType = table.Column<int>(type: "int", nullable: true),
                    ActionUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    ImageUrl = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    ReadAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Role = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    Priority = table.Column<int>(type: "int", nullable: true),
                    Title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Body = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: false),
                    IsRead = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AppNotifications", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AppNotifications_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AuditLogs",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: true),
                    Action = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    EntityName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    EntityId = table.Column<int>(type: "int", nullable: true),
                    Details = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AuditLogs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AuditLogs_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Carts",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Carts", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Carts_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Orders",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    OrderType = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    AssetType = table.Column<int>(type: "int", nullable: false),
                    Weight = table.Column<decimal>(type: "decimal(18,3)", precision: 18, scale: 3, nullable: false),
                    Unit = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    UnitPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    TotalAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    OtpCode = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    PriceLockedUntilUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Orders", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Orders_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "RefreshTokens",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    TokenHash = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    ExpiresAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    RevokedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RefreshTokens", x => x.Id);
                    table.ForeignKey(
                        name: "FK_RefreshTokens_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Sellers",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    CompanyName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    CompanyCode = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    CommercialRegistrationNumber = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    VatNumber = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    BusinessActivity = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    EstablishedDate = table.Column<DateOnly>(type: "date", nullable: true),
                    CompanyPhone = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    CompanyEmail = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Website = table.Column<string>(type: "nvarchar(250)", maxLength: 250, nullable: true),
                    Description = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: true),
                    MarketType = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    KycStatus = table.Column<int>(type: "int", nullable: false),
                    ReviewedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ReviewNotes = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    GoldAskPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: true),
                    GoldBidPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: true),
                    SilverAskPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: true),
                    SilverBidPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: true),
                    DiamondAskPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: true),
                    DiamondBidPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: true),
                    MarketCurrencyCode = table.Column<string>(type: "nvarchar(8)", maxLength: 8, nullable: false, defaultValue: "USD"),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Sellers", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Sellers_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "UserProfiles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    DateOfBirth = table.Column<DateOnly>(type: "date", nullable: true),
                    Nationality = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    DocumentType = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    IdNumber = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    ProfilePhotoUrl = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PreferredLanguage = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false),
                    PreferredTheme = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    MarketType = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false, defaultValue: "UAE"),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserProfiles", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserProfiles_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UserPushTokens",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    DeviceToken = table.Column<string>(type: "nvarchar(512)", maxLength: 512, nullable: false),
                    Platform = table.Column<int>(type: "int", nullable: false),
                    DeviceName = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserPushTokens", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserPushTokens_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Wallets",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    CashBalance = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    CurrencyCode = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Wallets", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Wallets_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PaymentTransactions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    OrderId = table.Column<int>(type: "int", nullable: false),
                    Amount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    PaymentMethod = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    ExternalTransactionId = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PaymentTransactions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PaymentTransactions_Orders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "Orders",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Products",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Sku = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: false),
                    ImageUrl = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: false),
                    VideoUrl = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: false),
                    Category = table.Column<int>(type: "int", nullable: false),
                    MaterialType = table.Column<int>(type: "int", nullable: false),
                    FormType = table.Column<int>(type: "int", nullable: false),
                    PricingMode = table.Column<int>(type: "int", nullable: false),
                    PurityKarat = table.Column<int>(type: "int", nullable: false),
                    PurityFactor = table.Column<decimal>(type: "decimal(10,6)", precision: 10, scale: 6, nullable: false),
                    WeightValue = table.Column<decimal>(type: "decimal(18,3)", precision: 18, scale: 3, nullable: false),
                    WeightUnit = table.Column<int>(type: "int", nullable: false),
                    BaseMarketPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    AutoPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    FixedPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    AskPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    BidPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    CurrencyCode = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false, defaultValue: "USD"),
                    OfferPercent = table.Column<decimal>(type: "decimal(8,3)", precision: 8, scale: 3, nullable: false),
                    OfferNewPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    OfferType = table.Column<int>(type: "int", nullable: false),
                    IsHasOffer = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
                    AvailableStock = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    SellerId = table.Column<int>(type: "int", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Products", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Products_Sellers_SellerId",
                        column: x => x.SellerId,
                        principalTable: "Sellers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "SellerAddresses",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SellerId = table.Column<int>(type: "int", nullable: false),
                    Country = table.Column<string>(type: "nvarchar(80)", maxLength: 80, nullable: false),
                    City = table.Column<string>(type: "nvarchar(80)", maxLength: 80, nullable: false),
                    Street = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    BuildingNumber = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    PostalCode = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SellerAddresses", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SellerAddresses_Sellers_SellerId",
                        column: x => x.SellerId,
                        principalTable: "Sellers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SellerBankAccounts",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SellerId = table.Column<int>(type: "int", nullable: false),
                    BankName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    AccountHolderName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    AccountNumber = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    IBAN = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    SwiftCode = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    BankCountry = table.Column<string>(type: "nvarchar(80)", maxLength: 80, nullable: false),
                    BankCity = table.Column<string>(type: "nvarchar(80)", maxLength: 80, nullable: false),
                    BranchName = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: false),
                    BranchAddress = table.Column<string>(type: "nvarchar(250)", maxLength: 250, nullable: false),
                    Currency = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false),
                    IsMainAccount = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SellerBankAccounts", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SellerBankAccounts_Sellers_SellerId",
                        column: x => x.SellerId,
                        principalTable: "Sellers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SellerBranches",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SellerId = table.Column<int>(type: "int", nullable: false),
                    BranchName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Country = table.Column<string>(type: "nvarchar(80)", maxLength: 80, nullable: false),
                    City = table.Column<string>(type: "nvarchar(80)", maxLength: 80, nullable: false),
                    FullAddress = table.Column<string>(type: "nvarchar(250)", maxLength: 250, nullable: false),
                    BuildingNumber = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    PostalCode = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    PhoneNumber = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    IsMainBranch = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SellerBranches", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SellerBranches_Sellers_SellerId",
                        column: x => x.SellerId,
                        principalTable: "Sellers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SellerDocuments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SellerId = table.Column<int>(type: "int", nullable: false),
                    DocumentType = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    FileName = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    FilePath = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    ContentType = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    IsRequired = table.Column<bool>(type: "bit", nullable: false),
                    UploadedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    RelatedEntityType = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    RelatedEntityId = table.Column<int>(type: "int", nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SellerDocuments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SellerDocuments_Sellers_SellerId",
                        column: x => x.SellerId,
                        principalTable: "Sellers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SellerManagers",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SellerId = table.Column<int>(type: "int", nullable: false),
                    FullName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    PositionTitle = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Nationality = table.Column<string>(type: "nvarchar(80)", maxLength: 80, nullable: false),
                    MobileNumber = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    EmailAddress = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    IdType = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    IdNumber = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    IdExpiryDate = table.Column<DateOnly>(type: "date", nullable: true),
                    IsPrimary = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SellerManagers", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SellerManagers_Sellers_SellerId",
                        column: x => x.SellerId,
                        principalTable: "Sellers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "LinkedBankAccounts",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserProfileId = table.Column<int>(type: "int", nullable: false),
                    BankName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    IbanMasked = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    IsVerified = table.Column<bool>(type: "bit", nullable: false),
                    IsDefault = table.Column<bool>(type: "bit", nullable: false),
                    AccountHolderName = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: false),
                    AccountNumber = table.Column<string>(type: "nvarchar(40)", maxLength: 40, nullable: false),
                    SwiftCode = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    BranchName = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: false),
                    BranchAddress = table.Column<string>(type: "nvarchar(250)", maxLength: 250, nullable: false),
                    Country = table.Column<string>(type: "nvarchar(80)", maxLength: 80, nullable: false),
                    City = table.Column<string>(type: "nvarchar(80)", maxLength: 80, nullable: false),
                    Currency = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LinkedBankAccounts", x => x.Id);
                    table.ForeignKey(
                        name: "FK_LinkedBankAccounts_UserProfiles_UserProfileId",
                        column: x => x.UserProfileId,
                        principalTable: "UserProfiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PaymentMethods",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserProfileId = table.Column<int>(type: "int", nullable: false),
                    Type = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    MaskedNumber = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    IsDefault = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PaymentMethods", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PaymentMethods_UserProfiles_UserProfileId",
                        column: x => x.UserProfileId,
                        principalTable: "UserProfiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "WalletAssets",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    WalletId = table.Column<int>(type: "int", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: true),
                    ProductName = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    ProductSku = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ProductImageUrl = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    MaterialType = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    FormType = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    PurityKarat = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: true),
                    PurityDisplayName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    WeightValue = table.Column<decimal>(type: "decimal(18,3)", precision: 18, scale: 3, nullable: false),
                    WeightUnit = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    AssetType = table.Column<int>(type: "int", nullable: false),
                    Category = table.Column<int>(type: "int", nullable: false),
                    SellerId = table.Column<int>(type: "int", nullable: true),
                    Weight = table.Column<decimal>(type: "decimal(18,3)", precision: 18, scale: 3, nullable: false),
                    Unit = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    Purity = table.Column<decimal>(type: "decimal(5,2)", precision: 5, scale: 2, nullable: false),
                    Quantity = table.Column<int>(type: "int", nullable: false),
                    AverageBuyPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    CurrentMarketPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    AcquisitionSubTotalAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    AcquisitionFeesAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    AcquisitionDiscountAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    AcquisitionFinalAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    LastTransactionHistoryId = table.Column<int>(type: "int", nullable: true),
                    SourceInvoiceId = table.Column<int>(type: "int", nullable: true),
                    SellerName = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WalletAssets", x => x.Id);
                    table.ForeignKey(
                        name: "FK_WalletAssets_Sellers_SellerId",
                        column: x => x.SellerId,
                        principalTable: "Sellers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_WalletAssets_Wallets_WalletId",
                        column: x => x.WalletId,
                        principalTable: "Wallets",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "CartItems",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CartId = table.Column<int>(type: "int", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: false),
                    SellerId = table.Column<int>(type: "int", nullable: true),
                    Category = table.Column<int>(type: "int", nullable: false),
                    Quantity = table.Column<int>(type: "int", nullable: false),
                    UnitPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    LineTotal = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CartItems", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CartItems_Carts_CartId",
                        column: x => x.CartId,
                        principalTable: "Carts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_CartItems_Products_ProductId",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_CartItems_Sellers_SellerId",
                        column: x => x.SellerId,
                        principalTable: "Sellers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
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

            migrationBuilder.CreateTable(
                name: "ApplePayPaymentMethodDetails",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PaymentMethodId = table.Column<int>(type: "int", nullable: false),
                    ApplePayToken = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    AccountHolderName = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ApplePayPaymentMethodDetails", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ApplePayPaymentMethodDetails_PaymentMethods_PaymentMethodId",
                        column: x => x.PaymentMethodId,
                        principalTable: "PaymentMethods",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "CardPaymentMethodDetails",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PaymentMethodId = table.Column<int>(type: "int", nullable: false),
                    CardNumber = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    CardHolderName = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: false),
                    Expiry = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CardPaymentMethodDetails", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CardPaymentMethodDetails_PaymentMethods_PaymentMethodId",
                        column: x => x.PaymentMethodId,
                        principalTable: "PaymentMethods",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "CliqPaymentMethodDetails",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PaymentMethodId = table.Column<int>(type: "int", nullable: false),
                    CliqAlias = table.Column<string>(type: "nvarchar(60)", maxLength: 60, nullable: false),
                    BankName = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: false),
                    AccountHolderName = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CliqPaymentMethodDetails", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CliqPaymentMethodDetails_PaymentMethods_PaymentMethodId",
                        column: x => x.PaymentMethodId,
                        principalTable: "PaymentMethods",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "WalletPaymentMethodDetails",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PaymentMethodId = table.Column<int>(type: "int", nullable: false),
                    Provider = table.Column<string>(type: "nvarchar(60)", maxLength: 60, nullable: false),
                    WalletNumber = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    AccountHolderName = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WalletPaymentMethodDetails", x => x.Id);
                    table.ForeignKey(
                        name: "FK_WalletPaymentMethodDetails_PaymentMethods_PaymentMethodId",
                        column: x => x.PaymentMethodId,
                        principalTable: "PaymentMethods",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Invoices",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    InvestorUserId = table.Column<int>(type: "int", nullable: false),
                    SellerUserId = table.Column<int>(type: "int", nullable: false),
                    InvoiceNumber = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    InvoiceCategory = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    SourceChannel = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    ExternalReference = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: true),
                    SubTotal = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    FeesAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    DiscountAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    TaxAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    TotalAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    Currency = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false),
                    PaymentMethod = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    PaymentStatus = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    PaymentTransactionId = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: true),
                    WalletItemId = table.Column<int>(type: "int", nullable: true),
                    ProductId = table.Column<int>(type: "int", nullable: true),
                    ProductName = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Quantity = table.Column<int>(type: "int", nullable: false),
                    UnitPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    Weight = table.Column<decimal>(type: "decimal(18,3)", precision: 18, scale: 3, nullable: false),
                    Purity = table.Column<decimal>(type: "decimal(5,2)", precision: 5, scale: 2, nullable: false),
                    FromPartyType = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: true),
                    ToPartyType = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: true),
                    FromPartyUserId = table.Column<int>(type: "int", nullable: true),
                    ToPartyUserId = table.Column<int>(type: "int", nullable: true),
                    OwnershipEffectiveOnUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    RelatedTransactionId = table.Column<int>(type: "int", nullable: true),
                    InvoiceQrCode = table.Column<string>(type: "nvarchar(300)", maxLength: 300, nullable: false),
                    PdfUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    IssuedOnUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    PaidOnUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Invoices", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Invoices_Products_ProductId",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_Invoices_Users_FromPartyUserId",
                        column: x => x.FromPartyUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Invoices_Users_InvestorUserId",
                        column: x => x.InvestorUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Invoices_Users_SellerUserId",
                        column: x => x.SellerUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Invoices_Users_ToPartyUserId",
                        column: x => x.ToPartyUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Invoices_WalletAssets_WalletItemId",
                        column: x => x.WalletItemId,
                        principalTable: "WalletAssets",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "TransactionHistories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    SellerId = table.Column<int>(type: "int", nullable: true),
                    TransactionType = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Status = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    Category = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Quantity = table.Column<int>(type: "int", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: true),
                    UnitPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    Weight = table.Column<decimal>(type: "decimal(18,3)", precision: 18, scale: 3, nullable: false),
                    Unit = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    Purity = table.Column<decimal>(type: "decimal(5,2)", precision: 5, scale: 2, nullable: false),
                    Notes = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: false),
                    Amount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    SubTotalAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    TotalFeesAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    DiscountAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    FinalAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    Currency = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false),
                    WalletItemId = table.Column<int>(type: "int", nullable: true),
                    InvoiceId = table.Column<int>(type: "int", nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TransactionHistories", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TransactionHistories_Invoices_InvoiceId",
                        column: x => x.InvoiceId,
                        principalTable: "Invoices",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_TransactionHistories_Sellers_SellerId",
                        column: x => x.SellerId,
                        principalTable: "Sellers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_TransactionHistories_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_TransactionHistories_WalletAssets_WalletItemId",
                        column: x => x.WalletItemId,
                        principalTable: "WalletAssets",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.InsertData(
                table: "SystemConfigration",
                columns: new[] { "Id", "ConfigKey", "CreatedAtUtc", "Description", "Name", "UpdatedAtUtc", "ValueBool", "ValueDecimal", "ValueInt", "ValueString", "ValueType" },
                values: new object[,]
                {
                    { 1, "WalletSell_Mode", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Wallet sell execution behavior for mobile and web", "Wallet Sell Mode", null, null, null, null, "locked_30_seconds", 1 },
                    { 2, "WalletSell_LockSeconds", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Wallet sell lock duration in seconds", "Wallet Sell Lock Seconds", null, null, null, 30, null, 3 },
                    { 3, "MobileRelease_IsIndividualSeller", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Mobile release: show single seller mode", "Mobile Release Is Individual Seller", null, false, null, null, null, 2 },
                    { 4, "MobileRelease_IndividualSellerName", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Mobile release seller name when single seller mode is enabled", "Mobile Release Individual Seller Name", null, null, null, null, "Imseeh", 1 },
                    { 5, "MobileRelease_ShowWeightInGrams", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Mobile release flag to show weight in grams", "Mobile Release Show Weight In Grams", null, true, null, null, null, 2 },
                    { 6, "MobileRelease_MarketWatchEnabled", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Mobile release flag to enable Market Watch tab in Product screen", "Mobile Release Market Watch Enabled", null, false, null, null, null, 2 },
                    { 7, "MobileRelease_MyAccountSummaryEnabled", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Mobile release flag to show My Account Summary entry in top bar", "Mobile Release My Account Summary Enabled", null, false, null, null, null, 2 },
                    { 8, "MobileSecurity_LoginByBiometric", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Allow biometric quick unlock on mobile", "Mobile Security Login By Biometric", null, true, null, null, null, 2 },
                    { 9, "Product_VideoMaxDurationSeconds", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Max allowed uploaded product video duration in seconds", "Product Video Max Duration Seconds", null, null, null, 30, null, 3 },
                    { 10, "MobileSecurity_LoginByPin", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Allow PIN quick unlock on mobile", "Mobile Security Login By PIN", null, true, null, null, null, 2 },
                    { 11, "Otp_EnableWhatsapp", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Enable WhatsApp OTP delivery channel", "OTP Enable WhatsApp", null, true, null, null, null, 2 },
                    { 12, "Otp_EnableEmail", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Enable Email OTP delivery channel", "OTP Enable Email", null, true, null, null, null, 2 },
                    { 13, "Otp_ExpirySeconds", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "OTP code expiry duration in seconds", "OTP Expiry Seconds", null, null, null, 300, null, 3 },
                    { 14, "Otp_ResendCooldownSeconds", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "OTP resend cooldown in seconds", "OTP Resend Cooldown Seconds", null, null, null, 30, null, 3 },
                    { 15, "Otp_MaxResendCount", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Maximum number of OTP resend attempts", "OTP Max Resend Count", null, null, null, 3, null, 3 },
                    { 16, "Otp_MaxVerificationAttempts", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Maximum OTP verification attempts before lock", "OTP Max Verification Attempts", null, null, null, 5, null, 3 },
                    { 17, "Otp_ChannelPriority", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Preferred OTP channels in order", "OTP Channel Priority", null, null, null, null, "whatsapp,email", 1 },
                    { 18, "Otp_RequiredActions", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Actions that require OTP verification", "OTP Required Actions", null, null, null, null, "registration,reset_password,checkout,sell,transfer,gift,pickup,add_bank_account,edit_bank_account,remove_bank_account,add_payment_method,edit_payment_method,remove_payment_method,change_email,change_password,change_mobile_number", 1 },
                    { 19, "Notifications_SellerKycApprove_EmailTemplate", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Email template used when seller KYC is approved", "Seller KYC Approve Email Template", null, null, null, null, "Hello {SellerName}, your KYC request was approved.", 1 },
                    { 20, "Notifications_SellerKycApprove_WhatsappTemplate", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "WhatsApp template used when seller KYC is approved", "Seller KYC Approve WhatsApp Template", null, null, null, null, "KYC approved for {SellerName}.", 1 },
                    { 21, "Notifications_SellerKycReject_EmailTemplate", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Email template used when seller KYC is rejected", "Seller KYC Reject Email Template", null, null, null, null, "Hello {SellerName}, your KYC request was rejected. Note: {ReviewNote}", 1 },
                    { 22, "Notifications_SellerKycReject_WhatsappTemplate", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "WhatsApp template used when seller KYC is rejected", "Seller KYC Reject WhatsApp Template", null, null, null, null, "KYC rejected for {SellerName}. Note: {ReviewNote}", 1 },
                    { 23, "Notifications_EmailSender_Name", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Display name for outbound system email notifications", "Email Sender Name", null, null, null, null, "Gold Wallet", 1 },
                    { 24, "Notifications_EmailSender_Address", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Sender email address for outbound notifications", "Email Sender Address", null, null, null, null, "no-reply@goldwallet.local", 1 },
                    { 25, "Notifications_WhatsappSender_Number", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Configured sender number for outbound WhatsApp notifications", "WhatsApp Sender Number", null, null, null, null, "+14155238886", 1 },
                    { 26, "Notifications_WhatsappSender_BusinessName", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Configured sender business name for outbound WhatsApp notifications", "WhatsApp Sender Business Name", null, null, null, null, "Gold Wallet", 1 }
                });

            migrationBuilder.InsertData(
                table: "SystemConfigration",
                columns: new[] { "Id", "ConfigKey", "CreatedAtUtc", "Description", "Name", "SellerAccess", "UpdatedAtUtc", "ValueBool", "ValueDecimal", "ValueInt", "ValueString", "ValueType" },
                values: new object[,]
                {
                    { 27, "Terms_Seller_TermsAndConditions", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Seller terms shown during seller registration", "Seller Terms and Conditions", true, null, null, null, null, "Seller terms placeholder.", 1 },
                    { 28, "Terms_Investor_TermsAndConditions", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Investor terms shown during investor registration", "Investor Terms and Conditions", true, null, null, null, null, "Investor terms placeholder.", 1 }
                });

            migrationBuilder.InsertData(
                table: "SystemFeeTypes",
                columns: new[] { "Id", "AppliesToBuy", "AppliesToGift", "AppliesToInvoice", "AppliesToPickup", "AppliesToReports", "AppliesToSell", "AppliesToTransfer", "CreatedAtUtc", "Description", "FeeCode", "IsEnabled", "Name", "SortOrder", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 1, true, false, true, false, true, true, false, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Seller managed commission fee", "commission_per_transaction", true, "Commission Per Transaction", 1, null },
                    { 2, false, false, true, true, true, false, false, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Seller managed premium or discount fee", "premium_discount", true, "Premium / Discount", 2, null },
                    { 3, false, false, true, true, true, false, false, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Seller managed custody fee", "storage_custody_fee", true, "Storage / Custody Fee", 3, null },
                    { 4, false, false, true, true, true, false, false, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Seller managed delivery fee", "delivery_fee", true, "Delivery Fee", 4, null }
                });

            migrationBuilder.InsertData(
                table: "SystemFeeTypes",
                columns: new[] { "Id", "AppliesToBuy", "AppliesToGift", "AppliesToInvoice", "AppliesToPickup", "AppliesToReports", "AppliesToSell", "AppliesToTransfer", "CreatedAtUtc", "Description", "FeeCode", "IsAdminManaged", "IsEnabled", "Name", "SortOrder", "UpdatedAtUtc" },
                values: new object[] { 5, true, true, true, true, true, true, true, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Admin managed service fee", "service_fee", true, true, "Service Fee", 6, null });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "CreatedAtUtc", "Email", "FullName", "IsActive", "PasswordHash", "PhoneNumber", "Role", "UpdatedAtUtc" },
                values: new object[] { 100, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "admin@goldwallet.com", "Gold Wallet Admin", true, "PPJjw8OG+mRgfuQq0PwjBg==.I6aFJ1YwnTWLF8rajLp/30yOAXuGukxV5lx0zFoVuBo=.100000", "+15551010001", "Admin", null });

            migrationBuilder.CreateIndex(
                name: "IX_AdminTransactionFees_FeeCode",
                table: "AdminTransactionFees",
                column: "FeeCode",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ApplePayPaymentMethodDetails_PaymentMethodId",
                table: "ApplePayPaymentMethodDetails",
                column: "PaymentMethodId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_AppNotifications_CreatedAtUtc",
                table: "AppNotifications",
                column: "CreatedAtUtc");

            migrationBuilder.CreateIndex(
                name: "IX_AppNotifications_UserId",
                table: "AppNotifications",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_AppNotifications_UserId_IsRead",
                table: "AppNotifications",
                columns: new[] { "UserId", "IsRead" });

            migrationBuilder.CreateIndex(
                name: "IX_AuditLogs_CreatedAtUtc",
                table: "AuditLogs",
                column: "CreatedAtUtc");

            migrationBuilder.CreateIndex(
                name: "IX_AuditLogs_UserId",
                table: "AuditLogs",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_CardPaymentMethodDetails_PaymentMethodId",
                table: "CardPaymentMethodDetails",
                column: "PaymentMethodId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_CartItems_CartId_ProductId",
                table: "CartItems",
                columns: new[] { "CartId", "ProductId" });

            migrationBuilder.CreateIndex(
                name: "IX_CartItems_Category",
                table: "CartItems",
                column: "Category");

            migrationBuilder.CreateIndex(
                name: "IX_CartItems_ProductId",
                table: "CartItems",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_CartItems_SellerId",
                table: "CartItems",
                column: "SellerId");

            migrationBuilder.CreateIndex(
                name: "IX_Carts_UserId",
                table: "Carts",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_CliqPaymentMethodDetails_PaymentMethodId",
                table: "CliqPaymentMethodDetails",
                column: "PaymentMethodId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_FromPartyUserId",
                table: "Invoices",
                column: "FromPartyUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_InvestorUserId",
                table: "Invoices",
                column: "InvestorUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_InvoiceNumber",
                table: "Invoices",
                column: "InvoiceNumber",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_IssuedOnUtc",
                table: "Invoices",
                column: "IssuedOnUtc");

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_PaymentStatus",
                table: "Invoices",
                column: "PaymentStatus");

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_ProductId",
                table: "Invoices",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_RelatedTransactionId",
                table: "Invoices",
                column: "RelatedTransactionId");

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_SellerUserId",
                table: "Invoices",
                column: "SellerUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_ToPartyUserId",
                table: "Invoices",
                column: "ToPartyUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_WalletItemId",
                table: "Invoices",
                column: "WalletItemId");

            migrationBuilder.CreateIndex(
                name: "IX_LinkedBankAccounts_UserProfileId",
                table: "LinkedBankAccounts",
                column: "UserProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_OrderType",
                table: "Orders",
                column: "OrderType");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_PriceLockedUntilUtc",
                table: "Orders",
                column: "PriceLockedUntilUtc");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_Status",
                table: "Orders",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_UserId",
                table: "Orders",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_PaymentMethods_UserProfileId",
                table: "PaymentMethods",
                column: "UserProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_PaymentTransactions_ExternalTransactionId",
                table: "PaymentTransactions",
                column: "ExternalTransactionId",
                unique: true,
                filter: "[ExternalTransactionId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_PaymentTransactions_OrderId",
                table: "PaymentTransactions",
                column: "OrderId");

            migrationBuilder.CreateIndex(
                name: "IX_PaymentTransactions_Status",
                table: "PaymentTransactions",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_Products_Name",
                table: "Products",
                column: "Name");

            migrationBuilder.CreateIndex(
                name: "IX_Products_SellerId",
                table: "Products",
                column: "SellerId");

            migrationBuilder.CreateIndex(
                name: "IX_Products_Sku",
                table: "Products",
                column: "Sku",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_RefreshTokens_TokenHash",
                table: "RefreshTokens",
                column: "TokenHash",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_RefreshTokens_UserId_ExpiresAtUtc",
                table: "RefreshTokens",
                columns: new[] { "UserId", "ExpiresAtUtc" });

            migrationBuilder.CreateIndex(
                name: "IX_SellerAddresses_SellerId",
                table: "SellerAddresses",
                column: "SellerId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_SellerBankAccounts_SellerId",
                table: "SellerBankAccounts",
                column: "SellerId");

            migrationBuilder.CreateIndex(
                name: "IX_SellerBranches_SellerId",
                table: "SellerBranches",
                column: "SellerId");

            migrationBuilder.CreateIndex(
                name: "IX_SellerDocuments_SellerId",
                table: "SellerDocuments",
                column: "SellerId");

            migrationBuilder.CreateIndex(
                name: "IX_SellerDocuments_SellerId_DocumentType",
                table: "SellerDocuments",
                columns: new[] { "SellerId", "DocumentType" });

            migrationBuilder.CreateIndex(
                name: "IX_SellerManagers_SellerId",
                table: "SellerManagers",
                column: "SellerId");

            migrationBuilder.CreateIndex(
                name: "IX_SellerProductFees_ProductId",
                table: "SellerProductFees",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_SellerProductFees_SellerId_ProductId_FeeCode",
                table: "SellerProductFees",
                columns: new[] { "SellerId", "ProductId", "FeeCode" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Sellers_CompanyCode",
                table: "Sellers",
                column: "CompanyCode",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Sellers_CompanyName",
                table: "Sellers",
                column: "CompanyName");

            migrationBuilder.CreateIndex(
                name: "IX_Sellers_KycStatus",
                table: "Sellers",
                column: "KycStatus");

            migrationBuilder.CreateIndex(
                name: "IX_Sellers_UserId",
                table: "Sellers",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_SystemConfigration_ConfigKey",
                table: "SystemConfigration",
                column: "ConfigKey",
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

            migrationBuilder.CreateIndex(
                name: "IX_TransactionHistories_Category",
                table: "TransactionHistories",
                column: "Category");

            migrationBuilder.CreateIndex(
                name: "IX_TransactionHistories_CreatedAtUtc",
                table: "TransactionHistories",
                column: "CreatedAtUtc");

            migrationBuilder.CreateIndex(
                name: "IX_TransactionHistories_InvoiceId",
                table: "TransactionHistories",
                column: "InvoiceId");

            migrationBuilder.CreateIndex(
                name: "IX_TransactionHistories_ProductId",
                table: "TransactionHistories",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_TransactionHistories_SellerId",
                table: "TransactionHistories",
                column: "SellerId");

            migrationBuilder.CreateIndex(
                name: "IX_TransactionHistories_Status",
                table: "TransactionHistories",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_TransactionHistories_UserId",
                table: "TransactionHistories",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_TransactionHistories_WalletItemId",
                table: "TransactionHistories",
                column: "WalletItemId");

            migrationBuilder.CreateIndex(
                name: "IX_UserProfiles_UserId",
                table: "UserProfiles",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_UserPushTokens_UserId",
                table: "UserPushTokens",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_UserPushTokens_UserId_DeviceToken_Platform",
                table: "UserPushTokens",
                columns: new[] { "UserId", "DeviceToken", "Platform" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_Role",
                table: "Users",
                column: "Role");

            migrationBuilder.CreateIndex(
                name: "IX_WalletAssets_Category",
                table: "WalletAssets",
                column: "Category");

            migrationBuilder.CreateIndex(
                name: "IX_WalletAssets_LastTransactionHistoryId",
                table: "WalletAssets",
                column: "LastTransactionHistoryId");

            migrationBuilder.CreateIndex(
                name: "IX_WalletAssets_ProductId",
                table: "WalletAssets",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_WalletAssets_SellerId",
                table: "WalletAssets",
                column: "SellerId");

            migrationBuilder.CreateIndex(
                name: "IX_WalletAssets_SourceInvoiceId",
                table: "WalletAssets",
                column: "SourceInvoiceId");

            migrationBuilder.CreateIndex(
                name: "IX_WalletAssets_WalletId",
                table: "WalletAssets",
                column: "WalletId");

            migrationBuilder.CreateIndex(
                name: "IX_WalletPaymentMethodDetails_PaymentMethodId",
                table: "WalletPaymentMethodDetails",
                column: "PaymentMethodId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Wallets_UserId",
                table: "Wallets",
                column: "UserId",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Invoices_TransactionHistories_RelatedTransactionId",
                table: "Invoices",
                column: "RelatedTransactionId",
                principalTable: "TransactionHistories",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Invoices_Users_FromPartyUserId",
                table: "Invoices");

            migrationBuilder.DropForeignKey(
                name: "FK_Invoices_Users_InvestorUserId",
                table: "Invoices");

            migrationBuilder.DropForeignKey(
                name: "FK_Invoices_Users_SellerUserId",
                table: "Invoices");

            migrationBuilder.DropForeignKey(
                name: "FK_Invoices_Users_ToPartyUserId",
                table: "Invoices");

            migrationBuilder.DropForeignKey(
                name: "FK_Sellers_Users_UserId",
                table: "Sellers");

            migrationBuilder.DropForeignKey(
                name: "FK_TransactionHistories_Users_UserId",
                table: "TransactionHistories");

            migrationBuilder.DropForeignKey(
                name: "FK_Wallets_Users_UserId",
                table: "Wallets");

            migrationBuilder.DropForeignKey(
                name: "FK_Invoices_Products_ProductId",
                table: "Invoices");

            migrationBuilder.DropForeignKey(
                name: "FK_TransactionHistories_Sellers_SellerId",
                table: "TransactionHistories");

            migrationBuilder.DropForeignKey(
                name: "FK_WalletAssets_Sellers_SellerId",
                table: "WalletAssets");

            migrationBuilder.DropForeignKey(
                name: "FK_Invoices_TransactionHistories_RelatedTransactionId",
                table: "Invoices");

            migrationBuilder.DropTable(
                name: "AdminTransactionFees");

            migrationBuilder.DropTable(
                name: "ApplePayPaymentMethodDetails");

            migrationBuilder.DropTable(
                name: "AppNotifications");

            migrationBuilder.DropTable(
                name: "AuditLogs");

            migrationBuilder.DropTable(
                name: "CardPaymentMethodDetails");

            migrationBuilder.DropTable(
                name: "CartItems");

            migrationBuilder.DropTable(
                name: "CliqPaymentMethodDetails");

            migrationBuilder.DropTable(
                name: "LinkedBankAccounts");

            migrationBuilder.DropTable(
                name: "PaymentTransactions");

            migrationBuilder.DropTable(
                name: "RefreshTokens");

            migrationBuilder.DropTable(
                name: "SellerAddresses");

            migrationBuilder.DropTable(
                name: "SellerBankAccounts");

            migrationBuilder.DropTable(
                name: "SellerBranches");

            migrationBuilder.DropTable(
                name: "SellerDocuments");

            migrationBuilder.DropTable(
                name: "SellerManagers");

            migrationBuilder.DropTable(
                name: "SellerProductFees");

            migrationBuilder.DropTable(
                name: "SystemConfigration");

            migrationBuilder.DropTable(
                name: "SystemFeeTypes");

            migrationBuilder.DropTable(
                name: "TransactionFeeBreakdowns");

            migrationBuilder.DropTable(
                name: "UserPushTokens");

            migrationBuilder.DropTable(
                name: "WalletPaymentMethodDetails");

            migrationBuilder.DropTable(
                name: "Carts");

            migrationBuilder.DropTable(
                name: "Orders");

            migrationBuilder.DropTable(
                name: "PaymentMethods");

            migrationBuilder.DropTable(
                name: "UserProfiles");

            migrationBuilder.DropTable(
                name: "Users");

            migrationBuilder.DropTable(
                name: "Products");

            migrationBuilder.DropTable(
                name: "Sellers");

            migrationBuilder.DropTable(
                name: "TransactionHistories");

            migrationBuilder.DropTable(
                name: "Invoices");

            migrationBuilder.DropTable(
                name: "WalletAssets");

            migrationBuilder.DropTable(
                name: "Wallets");
        }
    }
}
