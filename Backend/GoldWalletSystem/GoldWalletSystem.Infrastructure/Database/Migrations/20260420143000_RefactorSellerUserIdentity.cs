using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GoldWalletSystem.Infrastructure.Database.Migrations;

public partial class RefactorSellerUserIdentity : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<int>(
            name: "UserId",
            table: "Sellers",
            type: "int",
            nullable: true);

        migrationBuilder.Sql(@"
UPDATE S
SET S.[UserId] = U.[Id]
FROM [Sellers] S
INNER JOIN [Users] U ON U.[Email] = S.[Email]
WHERE S.[UserId] IS NULL;");

        migrationBuilder.Sql(@"
IF EXISTS (SELECT 1 FROM [Sellers] WHERE [UserId] IS NULL)
BEGIN
    THROW 51000, 'Cannot migrate Sellers.UserId: one or more sellers do not match a user by email.', 1;
END;");

        migrationBuilder.DropForeignKey(
            name: "FK_Users_Sellers_SellerId",
            table: "Users");

        migrationBuilder.DropIndex(
            name: "IX_Users_SellerId",
            table: "Users");

        migrationBuilder.DropIndex(
            name: "IX_Sellers_Email",
            table: "Sellers");

        migrationBuilder.DropColumn(
            name: "SellerId",
            table: "Users");

        migrationBuilder.DropColumn(
            name: "Email",
            table: "Sellers");

        migrationBuilder.DropColumn(
            name: "PasswordHash",
            table: "Sellers");

        migrationBuilder.AlterColumn<int>(
            name: "UserId",
            table: "Sellers",
            type: "int",
            nullable: false,
            oldClrType: typeof(int),
            oldType: "int",
            oldNullable: true);

        migrationBuilder.CreateIndex(
            name: "IX_Sellers_UserId",
            table: "Sellers",
            column: "UserId",
            unique: true);

        migrationBuilder.AddForeignKey(
            name: "FK_Sellers_Users_UserId",
            table: "Sellers",
            column: "UserId",
            principalTable: "Users",
            principalColumn: "Id",
            onDelete: ReferentialAction.Restrict);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropForeignKey(
            name: "FK_Sellers_Users_UserId",
            table: "Sellers");

        migrationBuilder.DropIndex(
            name: "IX_Sellers_UserId",
            table: "Sellers");

        migrationBuilder.AlterColumn<int>(
            name: "UserId",
            table: "Sellers",
            type: "int",
            nullable: true,
            oldClrType: typeof(int),
            oldType: "int");

        migrationBuilder.AddColumn<int>(
            name: "SellerId",
            table: "Users",
            type: "int",
            nullable: true);

        migrationBuilder.AddColumn<string>(
            name: "Email",
            table: "Sellers",
            type: "nvarchar(200)",
            maxLength: 200,
            nullable: false,
            defaultValue: "");

        migrationBuilder.AddColumn<string>(
            name: "PasswordHash",
            table: "Sellers",
            type: "nvarchar(500)",
            maxLength: 500,
            nullable: false,
            defaultValue: "");

        migrationBuilder.Sql(@"
UPDATE U
SET U.[SellerId] = S.[Id]
FROM [Users] U
INNER JOIN [Sellers] S ON S.[UserId] = U.[Id]
WHERE U.[Role] = 'Seller';");

        migrationBuilder.Sql(@"
UPDATE S
SET S.[Email] = U.[Email],
    S.[PasswordHash] = U.[PasswordHash]
FROM [Sellers] S
INNER JOIN [Users] U ON U.[Id] = S.[UserId]");

        migrationBuilder.CreateIndex(
            name: "IX_Users_SellerId",
            table: "Users",
            column: "SellerId");

        migrationBuilder.CreateIndex(
            name: "IX_Sellers_Email",
            table: "Sellers",
            column: "Email",
            unique: true);

        migrationBuilder.AddForeignKey(
            name: "FK_Users_Sellers_SellerId",
            table: "Users",
            column: "SellerId",
            principalTable: "Sellers",
            principalColumn: "Id",
            onDelete: ReferentialAction.Restrict);

        migrationBuilder.DropColumn(
            name: "UserId",
            table: "Sellers");
    }
}
