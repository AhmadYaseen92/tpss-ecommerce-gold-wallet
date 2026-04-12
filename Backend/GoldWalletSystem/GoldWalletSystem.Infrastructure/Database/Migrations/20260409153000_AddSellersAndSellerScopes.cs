using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GoldWalletSystem.Infrastructure.Database.Migrations
{
    public partial class AddSellersAndSellerScopes : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Sellers",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Code = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    ContactEmail = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    ContactPhone = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Address = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Sellers", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "Sellers",
                columns: new[] { "Id", "Name", "Code", "ContactEmail", "ContactPhone", "Address", "IsActive", "CreatedAtUtc", "UpdatedAtUtc" },
                values: new object[] { 1, "Imseeh", "IMSEEH", "contact@imseeh.com", "+962700000001", "Amman, Jordan", true, DateTime.UtcNow, null });

            migrationBuilder.AddColumn<int>(
                name: "SellerId",
                table: "Users",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddColumn<int>(
                name: "SellerId",
                table: "Products",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.CreateIndex(
                name: "IX_Users_SellerId",
                table: "Users",
                column: "SellerId");

            migrationBuilder.CreateIndex(
                name: "IX_Products_SellerId",
                table: "Products",
                column: "SellerId");

            migrationBuilder.CreateIndex(
                name: "IX_Sellers_Code",
                table: "Sellers",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Sellers_Name",
                table: "Sellers",
                column: "Name");

            migrationBuilder.AddForeignKey(
                name: "FK_Products_Sellers_SellerId",
                table: "Products",
                column: "SellerId",
                principalTable: "Sellers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Users_Sellers_SellerId",
                table: "Users",
                column: "SellerId",
                principalTable: "Sellers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(name: "FK_Products_Sellers_SellerId", table: "Products");
            migrationBuilder.DropForeignKey(name: "FK_Users_Sellers_SellerId", table: "Users");

            migrationBuilder.DropTable(name: "Sellers");

            migrationBuilder.DropIndex(name: "IX_Users_SellerId", table: "Users");
            migrationBuilder.DropIndex(name: "IX_Products_SellerId", table: "Products");

            migrationBuilder.DropColumn(name: "SellerId", table: "Users");
            migrationBuilder.DropColumn(name: "SellerId", table: "Products");
        }
    }
}
