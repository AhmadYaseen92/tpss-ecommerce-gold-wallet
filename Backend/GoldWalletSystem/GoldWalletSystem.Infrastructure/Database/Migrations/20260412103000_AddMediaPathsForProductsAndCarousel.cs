using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GoldWalletSystem.Infrastructure.Database.Migrations
{
    public partial class AddMediaPathsForProductsAndCarousel : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ImageUrl",
                table: "Products",
                type: "nvarchar(1000)",
                maxLength: 1000,
                nullable: false,
                defaultValue: "");

            migrationBuilder.Sql(@"
UPDATE P
SET P.ImageUrl = CASE
    WHEN P.Name LIKE '%Gift%' OR P.Name LIKE '%Pack%' THEN '/images/products/gift-card.png'
    WHEN P.Name LIKE '%Necklace%' OR P.Name LIKE '%Ring%' OR P.Name LIKE '%Bracelet%' OR P.Name LIKE '%Pendant%' THEN '/images/products/jewelry.png'
    WHEN P.Name LIKE '%Coin%' THEN '/images/products/gold-coin.png'
    WHEN P.Name LIKE '%Silver%' THEN '/images/products/silver.png'
    ELSE '/images/products/gold-bar.png'
END
FROM Products P
WHERE ISNULL(P.ImageUrl, '') = '';
");

            migrationBuilder.Sql(@"
IF NOT EXISTS (SELECT 1 FROM MobileAppConfigurations WHERE ConfigKey = 'home.carousel.images')
BEGIN
    INSERT INTO MobileAppConfigurations
    (ConfigKey, JsonValue, IsEnabled, Description, CreatedAtUtc, UpdatedAtUtc)
    VALUES
    (
        'home.carousel.images',
        '[""/images/banners/banner-1.png"",""/images/banners/banner-2.png"",""/images/banners/banner-3.png""]',
        1,
        'Home carousel offer images (server paths)',
        SYSUTCDATETIME(),
        NULL
    );
END
");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ImageUrl",
                table: "Products");

            migrationBuilder.Sql("DELETE FROM MobileAppConfigurations WHERE ConfigKey = 'home.carousel.images';");
        }
    }
}
