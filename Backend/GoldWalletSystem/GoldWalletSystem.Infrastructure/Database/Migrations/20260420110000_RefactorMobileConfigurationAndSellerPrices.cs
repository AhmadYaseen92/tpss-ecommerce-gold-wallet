using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GoldWalletSystem.Infrastructure.Database.Migrations
{
    public partial class RefactorMobileConfigurationAndSellerPrices : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(name: "GoldPrice", table: "Sellers", type: "decimal(18,2)", nullable: true);
            migrationBuilder.AddColumn<decimal>(name: "SilverPrice", table: "Sellers", type: "decimal(18,2)", nullable: true);
            migrationBuilder.AddColumn<decimal>(name: "DiamondPrice", table: "Sellers", type: "decimal(18,2)", nullable: true);

            migrationBuilder.AddColumn<string>(name: "Name", table: "MobileAppConfigurations", type: "nvarchar(150)", maxLength: 150, nullable: false, defaultValue: "");
            migrationBuilder.AddColumn<int>(name: "ValueType", table: "MobileAppConfigurations", type: "int", nullable: false, defaultValue: 1);
            migrationBuilder.AddColumn<string>(name: "ValueString", table: "MobileAppConfigurations", type: "nvarchar(max)", nullable: true);
            migrationBuilder.AddColumn<bool>(name: "ValueBool", table: "MobileAppConfigurations", type: "bit", nullable: true);
            migrationBuilder.AddColumn<int>(name: "ValueInt", table: "MobileAppConfigurations", type: "int", nullable: true);
            migrationBuilder.AddColumn<decimal>(name: "ValueDecimal", table: "MobileAppConfigurations", type: "decimal(18,2)", nullable: true);
            migrationBuilder.AddColumn<bool>(name: "SellerAccess", table: "MobileAppConfigurations", type: "bit", nullable: false, defaultValue: false);

            migrationBuilder.Sql(@"
UPDATE s SET
    GoldPrice = TRY_CAST(JSON_VALUE(c.JsonValue, '$.goldPerOunce') AS decimal(18,2)),
    SilverPrice = TRY_CAST(JSON_VALUE(c.JsonValue, '$.silverPerOunce') AS decimal(18,2)),
    DiamondPrice = TRY_CAST(JSON_VALUE(c.JsonValue, '$.diamondPerCarat') AS decimal(18,2))
FROM Sellers s
INNER JOIN MobileAppConfigurations c ON c.ConfigKey = CONCAT('SellerMarketPrices_', s.Id);
");

            migrationBuilder.Sql(@"
UPDATE MobileAppConfigurations
SET Name = ConfigKey,
    ValueType = CASE
        WHEN ISJSON(JsonValue) = 1 AND LOWER(JsonValue) IN ('true','false') THEN 2
        WHEN ISJSON(JsonValue) = 1 THEN 1
        ELSE 1
    END,
    ValueString = CASE
        WHEN ISJSON(JsonValue) = 1 AND LOWER(JsonValue) IN ('true','false') THEN NULL
        ELSE JsonValue
    END,
    ValueBool = CASE
        WHEN LOWER(JsonValue) = 'true' THEN CAST(1 as bit)
        WHEN LOWER(JsonValue) = 'false' THEN CAST(0 as bit)
        ELSE NULL
    END,
    SellerAccess = 0;
");

            migrationBuilder.Sql("DELETE FROM MobileAppConfigurations WHERE ConfigKey LIKE 'SellerMarketPrices_%';");

            migrationBuilder.DropColumn(name: "JsonValue", table: "MobileAppConfigurations");
            migrationBuilder.DropColumn(name: "IsEnabled", table: "MobileAppConfigurations");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(name: "JsonValue", table: "MobileAppConfigurations", type: "nvarchar(max)", nullable: false, defaultValue: "{}");
            migrationBuilder.AddColumn<bool>(name: "IsEnabled", table: "MobileAppConfigurations", type: "bit", nullable: false, defaultValue: true);

            migrationBuilder.Sql(@"
UPDATE MobileAppConfigurations
SET JsonValue = COALESCE(
    CASE
        WHEN ValueType = 2 AND ValueBool IS NOT NULL THEN CASE WHEN ValueBool = 1 THEN 'true' ELSE 'false' END
        WHEN ValueType = 3 AND ValueInt IS NOT NULL THEN CAST(ValueInt AS nvarchar(50))
        WHEN ValueType = 4 AND ValueDecimal IS NOT NULL THEN CAST(ValueDecimal AS nvarchar(50))
        ELSE ValueString
    END,
    '{}'
),
IsEnabled = 1;");

            migrationBuilder.DropColumn(name: "Name", table: "MobileAppConfigurations");
            migrationBuilder.DropColumn(name: "ValueType", table: "MobileAppConfigurations");
            migrationBuilder.DropColumn(name: "ValueString", table: "MobileAppConfigurations");
            migrationBuilder.DropColumn(name: "ValueBool", table: "MobileAppConfigurations");
            migrationBuilder.DropColumn(name: "ValueInt", table: "MobileAppConfigurations");
            migrationBuilder.DropColumn(name: "ValueDecimal", table: "MobileAppConfigurations");
            migrationBuilder.DropColumn(name: "SellerAccess", table: "MobileAppConfigurations");

            migrationBuilder.DropColumn(name: "GoldPrice", table: "Sellers");
            migrationBuilder.DropColumn(name: "SilverPrice", table: "Sellers");
            migrationBuilder.DropColumn(name: "DiamondPrice", table: "Sellers");
        }
    }
}
