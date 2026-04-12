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
    WHEN P.Name LIKE '%Silver%' THEN 'https://www.pamp.com/sites/pamp/files/2024-10/pamp-1oz-silver-bar-usa-webimage-1000x1000px-obv.png'
    ELSE 'https://www.pamp.com/sites/pamp/files/2022-02/10g_1.png'
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
        '[""https://urdu.bharatexpress.com/wp-content/uploads/2025/12/collage-67.webp"",""https://nygoldco.com/wp-content/uploads/2026/01/Exchange-Old-Jewellery-For-24k-Gold-Silver-Bar-NYGOLD-Banner-2.jpg"",""https://www.goldmarket.fr/wp-content/uploads/2025/09/84fbec39thumbnail-1110x550.jpeg.webp""]',
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
