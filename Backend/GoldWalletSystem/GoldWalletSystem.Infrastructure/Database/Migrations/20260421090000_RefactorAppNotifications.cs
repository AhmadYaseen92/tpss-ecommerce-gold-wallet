using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GoldWalletSystem.Infrastructure.Database.Migrations
{
    public partial class RefactorAppNotifications : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ActionUrl",
                table: "AppNotifications",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ImageUrl",
                table: "AppNotifications",
                type: "nvarchar(1000)",
                maxLength: 1000,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Priority",
                table: "AppNotifications",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "ReadAtUtc",
                table: "AppNotifications",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ReferenceId",
                table: "AppNotifications",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ReferenceType",
                table: "AppNotifications",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Role",
                table: "AppNotifications",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Type",
                table: "AppNotifications",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.Sql(@"
                UPDATE AppNotifications
                SET [Type] = CASE
                    WHEN Title = 'KYC Pending' THEN 1
                    WHEN Title = 'Invoice Issued' THEN 2
                    WHEN Title = 'Request Updated' THEN 3
                    ELSE 0
                END;
            ");

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

            migrationBuilder.CreateIndex(
                name: "IX_UserPushTokens_UserId",
                table: "UserPushTokens",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_UserPushTokens_UserId_DeviceToken_Platform",
                table: "UserPushTokens",
                columns: new[] { "UserId", "DeviceToken", "Platform" },
                unique: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "UserPushTokens");

            migrationBuilder.DropColumn(name: "ActionUrl", table: "AppNotifications");
            migrationBuilder.DropColumn(name: "ImageUrl", table: "AppNotifications");
            migrationBuilder.DropColumn(name: "Priority", table: "AppNotifications");
            migrationBuilder.DropColumn(name: "ReadAtUtc", table: "AppNotifications");
            migrationBuilder.DropColumn(name: "ReferenceId", table: "AppNotifications");
            migrationBuilder.DropColumn(name: "ReferenceType", table: "AppNotifications");
            migrationBuilder.DropColumn(name: "Role", table: "AppNotifications");
            migrationBuilder.DropColumn(name: "Type", table: "AppNotifications");
        }
    }
}
