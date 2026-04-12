using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GoldWalletSystem.Infrastructure.Database.Migrations
{
    public partial class AddProductCategoryAndFixImageUrls : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
UPDATE [Products]
SET [ImageUrl] = N'/images/products/gold-bar.png'
WHERE [ImageUrl] IS NULL OR LTRIM(RTRIM([ImageUrl])) = N'';
""");

            migrationBuilder.AddColumn<int>(
                name: "Category",
                table: "Products",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.Sql("""
UPDATE P
SET [Category] = CASE
    WHEN P.[Name] LIKE N'%Gift Card%' THEN 10
    WHEN P.[Name] LIKE N'%Silver%' AND P.[Name] LIKE N'%Coin%' THEN 6
    WHEN P.[Name] LIKE N'%Coin%' THEN 5
    WHEN (P.[Name] LIKE N'%Bracelet%' OR P.[Name] LIKE N'%Necklace%' OR P.[Name] LIKE N'%Wedding Set%') AND P.[Name] LIKE N'%Silver%' THEN 9
    WHEN P.[Name] LIKE N'%Bracelet%' OR P.[Name] LIKE N'%Necklace%' OR P.[Name] LIKE N'%Wedding Set%' THEN 8
    WHEN P.[Name] LIKE N'%Silver%' THEN 2
    WHEN P.[Name] LIKE N'%Bar%' THEN 3
    ELSE 1
END
FROM [Products] P;
""");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Category",
                table: "Products");
        }
    }
}
